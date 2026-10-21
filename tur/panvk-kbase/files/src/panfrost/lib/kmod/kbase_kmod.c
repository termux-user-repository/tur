/*
 * Copyright © 2026 Collabora, Ltd.
 * SPDX-License-Identifier: MIT
 *
 * kmod backend for the ARM Mali kbase kernel driver (/dev/mali*).
 * Targets the Bifrost/Valhall kbase driver r32p0–r44p0, both the JM
 * (arch <= 9, uAPI 11.x) and CSF (arch >= 10, uAPI 1.x) flavours.
 *
 * Key architectural differences from the panthor / panfrost DRM backends
 * (see the panfork driver, src/panfrost/base/, for a working reference):
 *
 *  - kbase is not a DRM driver; the fd is not a DRM fd.  The handshake is:
 *    VERSION_CHECK (CSF nr 52 / JM nr 0) -> SET_FLAGS -> mmap() of the
 *    tracking page.  Every other ioctl returns -EPERM before that.
 *  - There are no GEM handles; we mint our own u32 handles for the
 *    pan_kmod handle_to_bo sparse array.
 *  - For 64-bit clients the kernel forces SAME_VA on all non-executable
 *    allocations: KBASE_IOCTL_MEM_ALLOC returns a cookie, and mmap()-ing
 *    the fd at that cookie establishes the mapping, with CPU VA == GPU VA.
 *    We therefore mmap() every BO right at allocation time and keep that
 *    mapping until the BO is freed (bo_mmap/bo_munmap ops return/release
 *    the cached mapping).  munmap() of a SAME_VA region frees the GPU
 *    mapping too (free-on-close), so bo_free relies on it.
 *  - GPU-executable BOs come from the EXEC_VA zone (initialised with
 *    KBASE_IOCTL_MEM_EXEC_INIT at device-open time) and return a real
 *    GPU VA, which doubles as the mmap offset for CPU access.
 *  - The GPU address space is implicit (one per context), so vm_create /
 *    vm_bind are thin wrappers that record the VAs assigned by the kernel.
 *  - drmPrimeFDToHandle() does not work on a kbase fd; pan_kmod_bo_import()
 *    will fail gracefully (returns NULL). dma-buf import / WSI is left for
 *    future work (KBASE_IOCTL_MEM_IMPORT).
 *  - Command submission (CSF queue groups / JM job atoms) is not wired up
 *    yet; this backend currently only supports device enumeration and
 *    memory management.
 */

#include <errno.h>
#include <fcntl.h>
#include <linux/dma-heap.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <poll.h>
#include <sys/mman.h>
#include <unistd.h>

#include "util/macros.h"
#include "util/os_time.h"
#include "util/u_atomic.h"
#include "util/u_math.h"
#include "util/log.h"

#include "drm-uapi/mali_kbase_ioctl.h"
/* Only used as the interchange format for CSF interface information; no
 * panthor functionality is required. */
#include "drm-uapi/panthor_drm.h"

#include "kbase_kmod.h"
#include "pan_kmod_backend.h"
#include "pan_props.h"
#include "pan_trace.h"

/* Forward declaration — the full definition is at the end of this file. */
const struct pan_kmod_ops kbase_kmod_ops;

/* -------------------------------------------------------------------------
 * Internal device / BO / VM objects
 * ---------------------------------------------------------------------- */

struct kbase_kmod_dev {
   struct pan_kmod_dev base;

   /* True for the CSF flavour of kbase (arch >= 10), false for JM. */
   bool is_csf;

   /* CSF interface information (CSF only), queried from
    * KBASE_IOCTL_CS_GET_GLB_IFACE and stored in the panthor uAPI layout
    * so CSF-generic code can consume either backend. */
   struct drm_panthor_csif_info csif_info;

   /* Tracking page mapped at BASE_MEM_MAP_TRACKING_HANDLE.  Required by
    * the kernel before any memory operation; unmapped at destroy time. */
   void *tracking_page;

   /* CSF USER register page (LATEST_FLUSH etc.), CSF only. */
   void *user_reg_page;

   /* Monotonically-increasing handle counter.
    * kbase has no GEM handles; we mint our own u32 handles for use with the
    * pan_kmod handle_to_bo sparse array. */
   uint32_t next_handle; /* accessed with p_atomic_inc */

   /* Android dma-heap used for BOs which need to be shared with WSI. */
   int dma_heap_fd;

   /* Set when the CSF notification stream reports a queue-group error.
    * Vulkan queue status queries use this latch instead of invalidating and
    * reading every GPU subqueue context on every submission. */
   uint32_t csf_error;

   /* A persistent kernel CPU queue turns GPU timeline writes into pollable
    * sync_file fences.  At most one CQS wait is pending on this queue. */
   struct {
      simple_mtx_t lock;
      base_kcpu_queue_id id;
      bool valid;
      bool pending;
      uint64_t addr;
      uint64_t target_minus_one;
      int fence_fd;
   } kcpu;
};

struct kbase_kmod_vm {
   struct pan_kmod_vm base;

   /* Nothing kbase-specific: the kernel manages one implicit address space
    * per context and assigns all VAs itself. */
};

struct kbase_kmod_bo {
   struct pan_kmod_bo base;

   /* GPU virtual address.  For SAME_VA allocations this equals the CPU
    * mapping address; for EXEC_VA-zone allocations it is the address
    * returned by KBASE_IOCTL_MEM_ALLOC; for NEED_MMAP (non-SAME_VA)
    * dma-heap imports it is req.out.gpu_va with a separate CPU mapping. */
   uint64_t gpu_va;

   /* CPU mapping established at allocation time, valid for the whole BO
    * lifetime.  bo_mmap returns it; bo_munmap is a no-op. */
   void *cpu_ptr;

   /* Mapping on the kbase fd which establishes the GPU VA.  This differs
    * from cpu_ptr for imported dma-bufs: Pixel kbase UMM mappings reserve the
    * GPU VA but reject CPU faults, so CPU access uses the dma-buf fd mapping.
    */
   void *gpu_mapping;

   /* Retained dma-buf for imported/shareable BOs, or -1 for native kbase
    * allocations.
    */
   int dmabuf_fd;

   /* Whether cpu_ptr was mapped by this BO and must be munmap()ed. */
   bool owns_cpu_mapping;

   /* Whether this is a SAME_VA region (freed by munmap()) or a zone
    * region (freed by KBASE_IOCTL_MEM_FREE). */
   bool same_va;

   /* Whether the kernel reported BASE_MEM_COHERENT_SYSTEM for this region.
    * Coherent regions need no KBASE_IOCTL_MEM_SYNC (which this DDK rejects
    * for dma-heap imports with EINVAL); the kernel keeps CPU/GPU coherent.
    */
   bool cpu_gpu_coherent;
};

bool
kbase_kmod_supports_dmabuf(const struct pan_kmod_dev *dev)
{
   const struct kbase_kmod_dev *kbase_dev =
      container_of(dev, const struct kbase_kmod_dev, base);

   return kbase_dev->dma_heap_fd >= 0;
}

/* -------------------------------------------------------------------------
 * GPU properties blob parsing helpers
 * ---------------------------------------------------------------------- */

/*
 * Each entry in the GPU props blob is encoded as:
 *   4 bytes header: (key << 2) | size_code
 *     size_code 0 → u8 (1 byte)
 *     size_code 1 → u16 (2 bytes)
 *     size_code 2 → u32 (4 bytes)
 *     size_code 3 → u64 (8 bytes)
 *   N bytes value
 */
static uint64_t
kbase_gpuprop_get(const uint8_t *buf, size_t buf_size,
                  uint32_t target_key, uint64_t default_val)
{
   size_t offset = 0;

   while (offset + 4 <= buf_size) {
      uint32_t hdr;
      memcpy(&hdr, buf + offset, 4);
      offset += 4;

      uint32_t key = hdr >> 2;
      uint32_t size_code = hdr & 0x3;
      uint32_t val_size = 1u << size_code;

      if (offset + val_size > buf_size)
         break;

      if (key == target_key) {
         uint64_t val = 0;
         memcpy(&val, buf + offset, val_size);
         return val;
      }

      offset += val_size;
   }

   return default_val;
}

/* Fetch the GPU props blob from the kernel.  Returns a heap-allocated buffer
 * (must be freed by the caller) and its byte length, or NULL on error. */
static uint8_t *
kbase_get_gpuprops(int fd, size_t *out_size)
{
   /* First call: size=0 probes the required buffer length. */
   struct kbase_ioctl_get_gpuprops req = { 0 };
   int ret = ioctl(fd, KBASE_IOCTL_GET_GPUPROPS, &req);
   if (ret < 0) {
      mesa_loge("kbase: KBASE_IOCTL_GET_GPUPROPS (probe) failed: %s",
                strerror(errno));
      return NULL;
   }

   size_t size = (size_t)ret;
   if (size == 0) {
      mesa_loge("kbase: KBASE_IOCTL_GET_GPUPROPS returned zero size");
      return NULL;
   }

   uint8_t *buf = malloc(size);
   if (!buf)
      return NULL;

   req.buffer = (uintptr_t)buf;
   req.size = (uint32_t)size;

   ret = ioctl(fd, KBASE_IOCTL_GET_GPUPROPS, &req);
   if (ret < 0) {
      mesa_loge("kbase: KBASE_IOCTL_GET_GPUPROPS (fill) failed: %s",
                strerror(errno));
      free(buf);
      return NULL;
   }

   *out_size = size;
   return buf;
}

static void
kbase_dev_query_props(struct kbase_kmod_dev *kbase_dev,
                      const uint8_t *buf, size_t buf_size)
{
   struct pan_kmod_dev_props *props = &kbase_dev->base.props;

   /* GPU ID
    *   product_id  = bits[31:16] of the GPU_ID register
    *   major_rev   = bits[15:12]
    *   minor_rev   = bits[11:4]
    *   version_status = bits[3:0]
    *
    * KBASE_GPUPROP_RAW_GPU_ID holds the complete 32-bit GPU_ID register.
    * If that property is absent (older drivers), fall back to reconstructing
    * from the individual fields. */
   uint32_t raw_gpu_id = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_GPU_ID, 0);

   if (raw_gpu_id) {
      /* gpu_id as used by pan_arch(): product_id (top 16 bits) << 16 |
       * revision (bottom 16 bits). */
      props->gpu_id = ((uint64_t)(raw_gpu_id & 0xffff0000u)) |
                      (uint64_t)(raw_gpu_id & 0xffffu);
   } else {
      /* Fallback: reassemble from individual props (older kbase). */
      uint32_t product_id     = (uint32_t)kbase_gpuprop_get(
         buf, buf_size, KBASE_GPUPROP_PRODUCT_ID, 0);
      uint32_t major_revision = (uint32_t)kbase_gpuprop_get(
         buf, buf_size, KBASE_GPUPROP_MAJOR_REVISION, 0);
      uint32_t minor_revision = (uint32_t)kbase_gpuprop_get(
         buf, buf_size, KBASE_GPUPROP_MINOR_REVISION, 0);
      uint32_t version_status = (uint32_t)kbase_gpuprop_get(
         buf, buf_size, KBASE_GPUPROP_VERSION_STATUS, 0);

      props->gpu_id = ((uint64_t)product_id << 16) |
                      ((uint64_t)(major_revision & 0xf) << 12) |
                      ((uint64_t)(minor_revision & 0xff) << 4) |
                      (uint64_t)(version_status & 0xf);
   }

   /* GPU variant (lower 8 bits of CORE_FEATURES register) */
   props->gpu_variant = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_CORE_FEATURES, 0) & 0xff;

   /* Hardware feature registers */
   props->shader_present = kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_SHADER_PRESENT, 0);
   props->tiler_features = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_TILER_FEATURES, 0);
   props->mem_features = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_MEM_FEATURES, 0);
   props->mmu_features = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_MMU_FEATURES, 0);

   /* TEXTURE_FEATURES_0..2 are consecutive keys, but TEXTURE_FEATURES_3
    * was added later and got a non-contiguous key. */
   STATIC_ASSERT(ARRAY_SIZE(props->texture_features) == 4);
   for (unsigned i = 0; i < 3; i++) {
      props->texture_features[i] = (uint32_t)kbase_gpuprop_get(
         buf, buf_size,
         KBASE_GPUPROP_RAW_TEXTURE_FEATURES_0 + i, 0);
   }
   props->texture_features[3] = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_TEXTURE_FEATURES_3, 0);

   /* AFBC_FEATURES has no equivalent in the kbase GPU props blob; panfork
    * reports 0 for it as well. */
   props->afbc_features = 0;

   /* Thread / core properties */
   props->max_threads_per_core = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_THREAD_MAX_THREADS, 0);
   props->max_threads_per_wg = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_THREAD_MAX_WORKGROUP_SIZE, 0);

   uint32_t thread_features = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_THREAD_FEATURES, 0);
   props->max_tasks_per_core = MAX2(thread_features >> 24, 1);
   props->num_registers_per_core = thread_features & 0xffff;

   props->max_tls_instance_per_core = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_TLS_ALLOC, 0);
   if (!props->max_tls_instance_per_core)
      props->max_tls_instance_per_core = props->max_threads_per_core;

   /* If num_registers_per_core is zero, use fallback defaults per arch. */
   if (!props->num_registers_per_core) {
      unsigned arch = pan_arch(props->gpu_id);
      switch (arch) {
      case 4:
      case 5:
         props->num_registers_per_core = props->max_threads_per_core * 4;
         break;
      case 6:
         props->num_registers_per_core = props->max_threads_per_core * 64;
         break;
      default:
         props->num_registers_per_core = props->max_threads_per_core * 32;
         break;
      }
   }

   /* Coherency: kbase raw coherency mode.
    * 0 = none, 1 = ACE-Lite, 2 = ACE.
    *
    * In pan_kmod, is_io_coherent means explicit CPU cache maintenance can be
    * skipped for WB_MMAP BOs. That is not true for this kbase backend: kbase
    * cached CPU mappings still need KBASE_IOCTL_MEM_SYNC before GPU access and
    * after GPU writes.
    */
   uint32_t coherency_mode = (uint32_t)kbase_gpuprop_get(
      buf, buf_size, KBASE_GPUPROP_RAW_COHERENCY_MODE, 0);
   props->is_io_coherent = false;

   /* Timestamp: expose if gpu_id is non-zero (safe assumption). */
   props->gpu_can_query_timestamp = (props->gpu_id != 0);
   props->timestamp_device_coherent = (coherency_mode != 0);
   /* The GPU cycle counter frequency is not exposed through the GPU props
    * blob in the kbase uAPI.  It can be inferred at runtime by correlating
    * KBASE_IOCTL_GET_CPU_GPU_TIMEINFO with OS monotonic time, but that
    * requires a sampling window.  Leave it as 0 so the upper layers use
    * OS timestamps instead of cycle counts; callers that need accurate
    * frequency should perform their own calibration. */
   props->timestamp_frequency = 0;

   /* Priorities: kbase currently only advertises medium. */
   props->allowed_group_priorities_mask =
      PAN_KMOD_GROUP_ALLOW_PRIORITY_MEDIUM |
      PAN_KMOD_GROUP_ALLOW_PRIORITY_LOW;

   /* kbase's SAME_VA/EXEC_VA allocations are exposed at the base 4 KiB
    * granularity.  Newer pan_kmod derives the VM bitmap from device props. */
   props->pgsize_bitmap = PAN_PGSIZE_4K;

   /* Supported BO flags. WB_MMAP is backed by BASE_MEM_CACHED_CPU and explicit
    * KBASE_IOCTL_MEM_SYNC operations in kbase_kmod_flush_bo_map_syncs().
    */
   props->supported_bo_flags = PAN_KMOD_BO_FLAG_EXECUTABLE |
                                PAN_KMOD_BO_FLAG_ALLOC_ON_FAULT |
                                PAN_KMOD_BO_FLAG_NO_MMAP |
                                PAN_KMOD_BO_FLAG_WB_MMAP |
                                PAN_KMOD_BO_FLAG_GPU_UNCACHED |
                                PAN_KMOD_BO_FLAG_CSF_EVENT;
}

/* -------------------------------------------------------------------------
 * Device creation / destruction
 * ---------------------------------------------------------------------- */

/* Query the CSF global interface and derive the information CSF-generic
 * code needs, in the panthor uAPI layout.  Returns 0 on success. */
static int
kbase_query_csif_info(int fd, struct drm_panthor_csif_info *csif)
{
   /* First call with zero sizes to learn the group/stream counts. */
   union kbase_ioctl_cs_get_glb_iface req = { 0 };
   if (ioctl(fd, KBASE_IOCTL_CS_GET_GLB_IFACE, &req) < 0) {
      mesa_loge("kbase: KBASE_IOCTL_CS_GET_GLB_IFACE (probe) failed: %s",
                strerror(errno));
      return -1;
   }

   uint32_t group_num = req.out.group_num;
   uint32_t total_stream_num = req.out.total_stream_num;

   if (!group_num || !total_stream_num) {
      mesa_loge("kbase: GLB interface reports no queue groups/streams");
      return -1;
   }

   struct basep_cs_group_control *groups =
      calloc(group_num, sizeof(*groups));
   struct basep_cs_stream_control *streams =
      calloc(total_stream_num, sizeof(*streams));
   if (!groups || !streams) {
      free(groups);
      free(streams);
      return -1;
   }

   req.in.max_group_num = group_num;
   req.in.max_total_stream_num = total_stream_num;
   req.in.groups_ptr = (uintptr_t)groups;
   req.in.streams_ptr = (uintptr_t)streams;

   int ret = ioctl(fd, KBASE_IOCTL_CS_GET_GLB_IFACE, &req);
   if (ret < 0) {
      mesa_loge("kbase: KBASE_IOCTL_CS_GET_GLB_IFACE (fill) failed: %s",
                strerror(errno));
      free(groups);
      free(streams);
      return -1;
   }

   /* Stream features nominally encode the work register count in [7:0]
    * and the scoreboard slot count in [15:8], but the encoding is not
    * reliable across kbase/firmware versions (a Pixel 7 kbase 1.38
    * reports a work register value that underflows the register file the
    * CS compiler was designed for).  Like panthor, read WORK_REGS, but
    * sanity-check it: shipping CSF parts have 96 (v10/v11) or 128 (v12+)
    * CS registers, 4 of them unpreserved.  Resolve implausible counts once
    * the architecture is known.  Only trust the scoreboard count when it
    * is in the plausible [PANVK-supported] 1..16 range. */
   uint32_t stream_features = streams[0].features;
   uint32_t scoreboard_slot_count = (stream_features >> 8) & 0xff;
   uint32_t cs_reg_count = (stream_features & 0xff) + 1;

   mesa_logd("kbase: GLB iface: version 0x%x, features 0x%x, %u groups, "
             "%u streams (stream 0: features 0x%x, group 0: %u streams, "
             "suspend size %u)",
             req.out.glb_version, req.out.features, group_num,
             total_stream_num, stream_features, groups[0].stream_num,
             groups[0].suspend_size);

   *csif = (struct drm_panthor_csif_info){
      .csg_slot_count = group_num,
      .cs_slot_count = groups[0].stream_num,
      .cs_reg_count = cs_reg_count,
      .scoreboard_slot_count =
         (scoreboard_slot_count - 1) < 16 ? scoreboard_slot_count : 8,
      /* Number of CS registers the FW may clobber; matches panthor's
       * CSF_UNPRESERVED_REG_COUNT. */
      .unpreserved_cs_reg_count = 4,
   };

   free(groups);
   free(streams);
   return 0;
}

const struct drm_panthor_csif_info *
kbase_kmod_get_csif_props(const struct pan_kmod_dev *dev)
{
   assert(dev->ops == &kbase_kmod_ops);

   struct kbase_kmod_dev *kbase_dev =
      container_of(dev, struct kbase_kmod_dev, base);

   assert(kbase_dev->is_csf);
   return &kbase_dev->csif_info;
}

uint32_t
kbase_kmod_get_flush_id(const struct pan_kmod_dev *dev)
{
   struct kbase_kmod_dev *kbase_dev =
      container_of(dev, struct kbase_kmod_dev, base);

   if (!kbase_dev->user_reg_page)
      return 0;

   return *(volatile uint32_t *)((uint8_t *)kbase_dev->user_reg_page +
                                 CS_USER_REG_LATEST_FLUSH);
}

/* -------------------------------------------------------------------------
 * CSF queue group / queue / tiler heap primitives
 * ---------------------------------------------------------------------- */

int
kbase_kmod_csf_group_create(struct pan_kmod_dev *dev, uint32_t cs_queue_count,
                            uint32_t *group_handle)
{
   STATIC_ASSERT(sizeof(union kbase_ioctl_cs_queue_group_create_1_18) == 40);
   STATIC_ASSERT(sizeof(union kbase_ioctl_cs_queue_group_create) == 112);

   /* Endpoint masks/maxes match what panfork uses on all CSF parts:
    * a single tiler unit, all fragment/compute endpoints.  Tiler heap growth
    * is serviced by the kernel OOM path, so no application CSI exception
    * handler is requested (BASE_CSF_TILER_OOM_EXCEPTION_FLAG was tried and
    * confirmed ineffective on this kernel: the group is terminated on an
    * unhandled OOM regardless).  On uAPI 1.25+ use the current ioctl layout
    * to ask the kernel to report recoverable CS faults through read(). */
   if (pan_kmod_driver_version_at_least(&dev->driver, 1, 25)) {
      union kbase_ioctl_cs_queue_group_create req = {
         .in = {
            .tiler_mask = 1,
            .fragment_mask = ~0ull,
            .compute_mask = ~0ull,
            .cs_min = cs_queue_count,
            .priority = 0, /* BASE_QUEUE_GROUP_PRIORITY_HIGH: resist CSG rotation so the
                              * Pixel kbase off-slot heap-reclaim shrinker cannot
                              * empty our tiler heaps under memory pressure. */
            .tiler_max = 1,
            .fragment_max = 64,
            .compute_max = 64,
            .cs_fault_report_enable = 1,
         },
      };

      if (ioctl(dev->fd, KBASE_IOCTL_CS_QUEUE_GROUP_CREATE, &req) == 0) {
         *group_handle = req.out.group_handle;
         mesa_logd("kbase: created CSF group %u with CS fault reporting",
                   *group_handle);
         return 0;
      }

      mesa_logw("kbase: current CS_QUEUE_GROUP_CREATE failed: %s; "
                "falling back to the 1.6 ABI",
                strerror(errno));
   }

   /* The legacy request remains the compatibility fallback and leaves tiler
    * OOM handling in the kernel, matching panfork's working CSF path. */
   union kbase_ioctl_cs_queue_group_create_1_6 req = {
      .in = {
         .tiler_mask = 1,
         .fragment_mask = ~0ull,
         .compute_mask = ~0ull,
         .cs_min = cs_queue_count,
         .priority = 0, /* BASE_QUEUE_GROUP_PRIORITY_HIGH: resist CSG rotation so the
                              * Pixel kbase off-slot heap-reclaim shrinker cannot
                              * empty our tiler heaps under memory pressure. */
         .tiler_max = 1,
         .fragment_max = 64,
         .compute_max = 64,
      },
   };

   if (ioctl(dev->fd, KBASE_IOCTL_CS_QUEUE_GROUP_CREATE_1_6, &req)) {
      mesa_loge("kbase: KBASE_IOCTL_CS_QUEUE_GROUP_CREATE failed: %s",
                strerror(errno));
      return -1;
   }

   *group_handle = req.out.group_handle;
   return 0;
}

static void
kbase_log_csf_queue_error(const char *kind, uint8_t group_handle,
                          uint8_t csi_index, uint32_t status,
                          uint64_t sideband, uint8_t has_extra,
                          uint32_t trace_id0, uint32_t trace_id1,
                          uint32_t trace_task)
{
   mesa_loge("kbase: CSF group %u CSI %u %s: status 0x%08x "
             "(exception 0x%02x), sideband 0x%016" PRIx64,
             group_handle, csi_index, kind, status, status & 0xff, sideband);

   if (has_extra) {
      mesa_loge("kbase: CSF group %u CSI %u fault trace: id0 0x%08x, "
                "id1 0x%08x, task 0x%08x",
                group_handle, csi_index, trace_id0, trace_id1, trace_task);
   }
}

static int
kbase_log_csf_notification(struct pan_kmod_dev *dev,
                           const struct base_csf_notification *event)
{
   STATIC_ASSERT(sizeof(struct base_csf_notification) == 64);

   if (event->type == BASE_CSF_NOTIFICATION_EVENT) {
      mesa_logd("kbase: received CSF event notification");
      return 0;
   }

   if (event->type == BASE_CSF_NOTIFICATION_CPU_QUEUE_DUMP) {
      mesa_logw("kbase: received CSF CPU queue dump notification");
      return 0;
   }

   if (event->type != BASE_CSF_NOTIFICATION_GPU_QUEUE_GROUP_ERROR) {
      mesa_logw("kbase: received unknown CSF notification type %u",
                event->type);
      return 0;
   }

   struct kbase_kmod_dev *kbase_dev =
      container_of(dev, struct kbase_kmod_dev, base);
   p_atomic_set(&kbase_dev->csf_error, true);

   const uint8_t group_handle = event->payload.csg_error.handle;
   const struct base_gpu_queue_group_error *error =
      &event->payload.csg_error.error;

   int error_type = error->error_type + 1;

   switch (error->error_type) {
   case BASE_GPU_QUEUE_GROUP_ERROR_FATAL: {
      const struct base_gpu_queue_group_error_fatal_payload *payload =
         &error->payload.fatal_group;
      mesa_loge("kbase: CSF group %u fatal error: status 0x%08x "
                "(exception 0x%02x), sideband 0x%016" PRIx64,
                group_handle, payload->status, payload->status & 0xff,
                (uint64_t)payload->sideband);
      break;
   }

   case BASE_GPU_QUEUE_GROUP_QUEUE_ERROR_FATAL: {
      const struct base_gpu_queue_error_fatal_payload *payload =
         &error->payload.fatal_queue;
      kbase_log_csf_queue_error(
         "fatal error", group_handle, payload->csi_index, payload->status,
         payload->sideband, payload->has_extra, payload->trace_id0,
         payload->trace_id1, payload->trace_task);
      break;
   }

   case BASE_GPU_QUEUE_GROUP_ERROR_TIMEOUT:
      mesa_loge("kbase: CSF group %u progress timeout notification",
                group_handle);
      break;

   case BASE_GPU_QUEUE_GROUP_ERROR_TILER_HEAP_OOM:
      mesa_loge("kbase: CSF group %u tiler heap OOM notification",
                group_handle);
      break;

   case BASE_GPU_QUEUE_GROUP_QUEUE_ERROR_FAULT: {
      const struct base_gpu_queue_error_fault_payload *payload =
         &error->payload.fault_queue;
      kbase_log_csf_queue_error(
         "recoverable fault", group_handle, payload->csi_index,
         payload->status, payload->sideband, payload->has_extra,
         payload->trace_id0, payload->trace_id1, payload->trace_task);
      break;
   }

   default:
      mesa_loge("kbase: CSF group %u unknown error type %u", group_handle,
                error->error_type);
      break;
   }
   return error_type;
}

void
kbase_kmod_csf_group_destroy(struct pan_kmod_dev *dev, uint32_t group_handle)
{
   struct kbase_ioctl_cs_queue_group_term req = {
      .group_handle = group_handle,
   };

   if (ioctl(dev->fd, KBASE_IOCTL_CS_QUEUE_GROUP_TERMINATE, &req))
      mesa_loge("kbase: KBASE_IOCTL_CS_QUEUE_GROUP_TERMINATE failed: %s",
                strerror(errno));
}

void *
kbase_kmod_csf_queue_bind(struct pan_kmod_dev *dev, uint32_t group_handle,
                          uint32_t csi_index, uint64_t ringbuf_va,
                          uint32_t ringbuf_size)
{
   struct kbase_ioctl_cs_queue_register reg = {
      .buffer_gpu_addr = ringbuf_va,
      .buffer_size = ringbuf_size,
      .priority = 0, /* BASE_QUEUE_GROUP_PRIORITY_HIGH: resist CSG rotation so the
                              * Pixel kbase off-slot heap-reclaim shrinker cannot
                              * empty our tiler heaps under memory pressure. */
   };

   if (ioctl(dev->fd, KBASE_IOCTL_CS_QUEUE_REGISTER, &reg)) {
      mesa_loge("kbase: KBASE_IOCTL_CS_QUEUE_REGISTER failed: %s",
                strerror(errno));
      return NULL;
   }

   union kbase_ioctl_cs_queue_bind bind = {
      .in = {
         .buffer_gpu_addr = ringbuf_va,
         .group_handle = group_handle,
         .csi_index = csi_index,
      },
   };

   if (ioctl(dev->fd, KBASE_IOCTL_CS_QUEUE_BIND, &bind)) {
      mesa_loge("kbase: KBASE_IOCTL_CS_QUEUE_BIND failed: %s",
                strerror(errno));
      goto err_term_queue;
   }

   void *user_io = mmap(NULL, BASEP_QUEUE_NR_MMAP_USER_PAGES * 4096,
                        PROT_READ | PROT_WRITE, MAP_SHARED, dev->fd,
                        bind.out.mmap_handle);
   if (user_io == MAP_FAILED) {
      mesa_loge("kbase: mmap of CS USER_IO pages failed: %s",
                strerror(errno));
      goto err_term_queue;
   }

   return user_io;

err_term_queue:
   {
      struct kbase_ioctl_cs_queue_terminate term = {
         .buffer_gpu_addr = ringbuf_va,
      };
      ioctl(dev->fd, KBASE_IOCTL_CS_QUEUE_TERMINATE, &term);
   }
   return NULL;
}

void
kbase_kmod_csf_queue_term(struct pan_kmod_dev *dev, uint64_t ringbuf_va,
                          void *user_io)
{
   if (user_io)
      munmap(user_io, BASEP_QUEUE_NR_MMAP_USER_PAGES * 4096);

   struct kbase_ioctl_cs_queue_terminate term = {
      .buffer_gpu_addr = ringbuf_va,
   };

   if (ioctl(dev->fd, KBASE_IOCTL_CS_QUEUE_TERMINATE, &term))
      mesa_loge("kbase: KBASE_IOCTL_CS_QUEUE_TERMINATE failed: %s",
                strerror(errno));
}

int
kbase_kmod_csf_queue_kick(struct pan_kmod_dev *dev, uint64_t ringbuf_va)
{
   struct kbase_ioctl_cs_queue_kick kick = {
      .buffer_gpu_addr = ringbuf_va,
   };

   if (ioctl(dev->fd, KBASE_IOCTL_CS_QUEUE_KICK, &kick)) {
      mesa_loge("kbase: KBASE_IOCTL_CS_QUEUE_KICK failed: %s",
                strerror(errno));
      return -1;
   }

   return 0;
}

int
kbase_kmod_csf_wait_event(struct pan_kmod_dev *dev, int64_t timeout_ns)
{
   /* Block until the kernel has a CSF notification pending, then consume one
    * notification with read().  This is what drives kernel-side
    * servicing of the submitted work (tiler-heap OOM growth, sync-update
    * wakeups, group scheduling) — a pure userspace spin on the seqno cell
    * never gives the driver's event path a chance to run.  Mirrors
    * panfork's poll()+read() CSF wait model. */
   struct pollfd pfd = {
      .fd = dev->fd,
      .events = POLLIN,
   };
   struct timespec ts = {
      .tv_sec = timeout_ns / 1000000000,
      .tv_nsec = timeout_ns % 1000000000,
   };

   int ret = ppoll(&pfd, 1, &ts, NULL);
   if (ret < 0)
      return (errno == EINTR) ? 0 : -1;

   if (ret == 0 || !(pfd.revents & POLLIN))
      return 0;

   /* The kbase fd is blocking.  Read exactly one notification after poll;
    * trying to drain it until EAGAIN would block forever after the final
    * pending record.  Another queued record will make the next poll return
    * immediately. */
   struct base_csf_notification event;
   ssize_t rd;

   do {
      rd = read(dev->fd, &event, sizeof(event));
   } while (rd < 0 && errno == EINTR);

   if (rd < 0)
      return -1;

   if (rd != sizeof(event)) {
      errno = EIO;
      return -1;
   }

   return kbase_log_csf_notification(dev, &event);
}

static int
kbase_kcpu_poll_fence(int fd, int64_t timeout_ns)
{
   struct pollfd pfd = {
      .fd = fd,
      .events = POLLIN,
   };
   struct timespec ts = {
      .tv_sec = timeout_ns / 1000000000,
      .tv_nsec = timeout_ns % 1000000000,
   };

   int ret;
   do {
      ret = ppoll(&pfd, 1, &ts, NULL);
   } while (ret < 0 && errno == EINTR);

   if (ret <= 0)
      return ret;

   /* sync_file reports a signalled fence through POLLIN.  POLLERR/HUP also
    * retires the KCPU command; the caller reads the adjacent CQS error word
    * before accepting queue completion. */
   return pfd.revents & (POLLIN | POLLERR | POLLHUP) ? 1 : -1;
}

int
kbase_kmod_csf_wait_cqs64(struct pan_kmod_dev *dev, uint64_t addr,
                          uint64_t target_minus_one, int64_t timeout_ns)
{
   struct kbase_kmod_dev *kbase_dev =
      container_of(dev, struct kbase_kmod_dev, base);
   int ret = -1;

   STATIC_ASSERT(sizeof(struct base_fence) == 8);
   STATIC_ASSERT(sizeof(struct base_cqs_wait_operation_info) == 24);
   STATIC_ASSERT(sizeof(struct base_kcpu_command) == 24);

   if (!kbase_dev->is_csf || (addr & 15))
      return -1;

   simple_mtx_lock(&kbase_dev->kcpu.lock);
   if (!kbase_dev->kcpu.valid)
      goto out;

   /* Reap an earlier wait first.  Normally it belongs to this same caller:
    * keeping it queued across a 20 ms userspace watchdog slice avoids
    * repeatedly creating fences for a long GPU job. */
   if (kbase_dev->kcpu.pending) {
      ret = kbase_kcpu_poll_fence(kbase_dev->kcpu.fence_fd, 0);
      if (ret == 1) {
         bool matches = kbase_dev->kcpu.addr == addr &&
                        kbase_dev->kcpu.target_minus_one == target_minus_one;
         close(kbase_dev->kcpu.fence_fd);
         kbase_dev->kcpu.fence_fd = -1;
         kbase_dev->kcpu.pending = false;
         if (matches)
            goto out;
      } else if (ret < 0) {
         mesa_logw("kbase: KCPU sync fence poll failed: %s", strerror(errno));
         goto disable;
      } else if (kbase_dev->kcpu.addr != addr ||
                 kbase_dev->kcpu.target_minus_one != target_minus_one) {
         /* One device context may back multiple Vulkan queues.  Do not put a
          * different wait behind the outstanding one: its caller can use the
          * existing CSF-notification fallback without head-of-line blocking. */
         ret = -1;
         goto out;
      } else {
         ret = kbase_kcpu_poll_fence(kbase_dev->kcpu.fence_fd, timeout_ns);
         if (ret < 0) {
            mesa_loge("kbase: kbase_kcpu_poll_fence (%d) failed: %s", __LINE__, strerror(errno));
         }
         if (ret == 1) {
            close(kbase_dev->kcpu.fence_fd);
            kbase_dev->kcpu.fence_fd = -1;
            kbase_dev->kcpu.pending = false;
         }
         goto out;
      }
   }

   struct base_cqs_wait_operation_info wait = {
      .addr = addr,
      .val = target_minus_one,
      .operation = BASEP_CQS_WAIT_OPERATION_GT,
      .data_type = BASEP_CQS_DATA_TYPE_U64,
   };
   struct base_fence fence = {
      .basep = {
         .fd = -1,
         .stream_fd = -1,
      },
   };
   struct base_kcpu_command commands[2] = {
      {
         .type = BASE_KCPU_COMMAND_TYPE_CQS_WAIT_OPERATION,
         .info.cqs_wait_operation = {
            .objs = (uintptr_t)&wait,
            .nr_objs = 1,
         },
      },
      {
         .type = BASE_KCPU_COMMAND_TYPE_FENCE_SIGNAL,
         .info.fence = {
            .fence = (uintptr_t)&fence,
         },
      },
   };
   struct kbase_ioctl_kcpu_queue_enqueue enqueue_wait = {
      .addr = (uintptr_t)&commands[0],
      .nr_commands = 1,
      .id = kbase_dev->kcpu.id,
   };
   struct kbase_ioctl_kcpu_queue_enqueue enqueue_fence = {
      .addr = (uintptr_t)&commands[1],
      .nr_commands = 1,
      .id = kbase_dev->kcpu.id,
   };

   /* The public ioctl envelope has a command count, but shipping kbase
    * implementations require exactly one command per enqueue.  Put the
    * fence behind the CQS wait with a second ioctl. */
   if (ioctl(dev->fd, KBASE_IOCTL_KCPU_QUEUE_ENQUEUE, &enqueue_wait) ||
       ioctl(dev->fd, KBASE_IOCTL_KCPU_QUEUE_ENQUEUE, &enqueue_fence) ||
       fence.basep.fd < 0) {
      mesa_logd("kbase: KCPU CQS wait unavailable: %s",
                fence.basep.fd < 0 && errno == 0 ? "no sync fence" :
                                                  strerror(errno));
      goto disable;
   }

   kbase_dev->kcpu.pending = true;
   kbase_dev->kcpu.addr = addr;
   kbase_dev->kcpu.target_minus_one = target_minus_one;
   kbase_dev->kcpu.fence_fd = fence.basep.fd;

   ret = kbase_kcpu_poll_fence(fence.basep.fd, timeout_ns);
   if (ret == 1) {
      close(kbase_dev->kcpu.fence_fd);
      kbase_dev->kcpu.fence_fd = -1;
      kbase_dev->kcpu.pending = false;
   } else if (ret < 0) {
      mesa_loge("kbase: kbase_kcpu_poll_fence failed: %s", strerror(errno));
      goto disable;
   }
   goto out;

disable:
   if (kbase_dev->kcpu.fence_fd >= 0) {
      close(kbase_dev->kcpu.fence_fd);
      kbase_dev->kcpu.fence_fd = -1;
   }
   kbase_dev->kcpu.pending = false;
   if (kbase_dev->kcpu.valid) {
      struct kbase_ioctl_kcpu_queue_delete delete = {
         .id = kbase_dev->kcpu.id,
      };
      ioctl(dev->fd, KBASE_IOCTL_KCPU_QUEUE_DELETE, &delete);
      kbase_dev->kcpu.valid = false;
   }
   mesa_loge("kbase: kcpu queue disabled due to error");
   ret = -1;

out:
   simple_mtx_unlock(&kbase_dev->kcpu.lock);
   return ret;
}

bool
kbase_kmod_csf_has_error(const struct pan_kmod_dev *dev)
{
   const struct kbase_kmod_dev *kbase_dev =
      container_of(dev, const struct kbase_kmod_dev, base);
   return p_atomic_read(&kbase_dev->csf_error);
}

int
kbase_kmod_csf_tiler_heap_create(struct pan_kmod_dev *dev,
                                 uint32_t chunk_size, uint32_t initial_chunks,
                                 uint32_t max_chunks,
                                 uint32_t target_in_flight,
                                 uint32_t mem_group_id,
                                 uint64_t *heap_ctx_va,
                                 uint64_t *first_chunk_va)
{
   /* The uAPI group_id is the physical memory group used for allocations,
    * not the CS queue group handle. */
   union kbase_ioctl_cs_tiler_heap_init req = {
      .in = {
         .chunk_size = chunk_size,
         .initial_chunks = initial_chunks,
         .max_chunks = max_chunks,
         .target_in_flight = MIN2(target_in_flight, UINT16_MAX),
         .group_id = mem_group_id,
      },
   };

   if (ioctl(dev->fd, KBASE_IOCTL_CS_TILER_HEAP_INIT, &req)) {
      mesa_loge("kbase: KBASE_IOCTL_CS_TILER_HEAP_INIT failed: %s",
                strerror(errno));
      return -1;
   }

   *heap_ctx_va = req.out.gpu_heap_va;
   *first_chunk_va = req.out.first_chunk_va;
   return 0;
}

void
kbase_kmod_csf_tiler_heap_destroy(struct pan_kmod_dev *dev,
                                  uint64_t heap_ctx_va)
{
   struct kbase_ioctl_cs_tiler_heap_term req = {
      .gpu_heap_va = heap_ctx_va,
   };

   if (ioctl(dev->fd, KBASE_IOCTL_CS_TILER_HEAP_TERM, &req))
      mesa_loge("kbase: KBASE_IOCTL_CS_TILER_HEAP_TERM failed: %s",
                strerror(errno));
}

uint64_t
kbase_kmod_alias_create(struct pan_kmod_dev *dev, uint64_t bo_va,
                        uint64_t size, uint32_t nents)
{
   const uint64_t page_size = 4096;
   uint64_t total = size * nents;
   struct base_mem_aliasing_info ai[4];

   assert(nents >= 1 && nents <= ARRAY_SIZE(ai));
   assert(!(size % page_size) && !(bo_va % page_size));

   for (uint32_t i = 0; i < nents; i++) {
      ai[i] = (struct base_mem_aliasing_info){
         .handle = bo_va,
         .offset = 0,
         .length = size / page_size,
      };
   }

   /* kbase's get_unmapped_area rejects MAP_FIXED and address hints
    * outright ("err on fixed address"), so the kernel always picks the
    * address.  Callers only need the mapping to not cross a 4G boundary
    * (so ring wraparound can be done with 32-bit maths), which a
    * kernel-picked address almost always satisfies — in the unlikely case
    * it doesn't, destroy the mapping and try again with a fresh alias
    * region. */
   for (unsigned attempt = 0; attempt < 16; attempt++) {
      /* Note: CPU_WR is not allowed on alias regions, and the source BO
       * must be GPU-cached and share the same coherency domain. */
      union kbase_ioctl_mem_alias req = {
         .in = {
            .flags = BASE_MEM_PROT_GPU_RD | BASE_MEM_PROT_GPU_WR |
                     BASE_MEM_PROT_CPU_RD,
            .stride = size / page_size,
            .nents = nents,
            .aliasing_info = (uintptr_t)ai,
         },
      };

      if (ioctl(dev->fd, KBASE_IOCTL_MEM_ALIAS, &req)) {
         mesa_loge("kbase: KBASE_IOCTL_MEM_ALIAS failed: %s",
                   strerror(errno));
         return 0;
      }

      /* For 64-bit clients the alias is a SAME_VA region: out.gpu_va is a
       * cookie and mmap()ing it establishes the mapping, with the
       * resulting address being both the CPU and GPU VA. */
      void *ptr =
         mmap(NULL, total, PROT_READ, MAP_SHARED, dev->fd, req.out.gpu_va);
      if (ptr == MAP_FAILED) {
         mesa_loge("kbase: mmap of alias region failed: %s",
                   strerror(errno));
         struct kbase_ioctl_mem_free free_req = { .gpu_addr = req.out.gpu_va };
         ioctl(dev->fd, KBASE_IOCTL_MEM_FREE, &free_req);
         return 0;
      }

      uint64_t va = (uintptr_t)ptr;

      if ((va >> 32) == ((va + total - 1) >> 32))
         return va;

      /* Crosses a 4G boundary: munmap destroys the SAME_VA alias region
       * (free-on-close), try again. */
      munmap(ptr, total);
   }

   mesa_loge("kbase: could not get an alias mapping that doesn't cross a "
             "4G boundary");
   return 0;
}

void
kbase_kmod_alias_destroy(struct pan_kmod_dev *dev, uint64_t va, uint64_t size,
                         uint32_t nents)
{
   /* SAME_VA region: munmap() tears down the GPU mapping too. */
   munmap((void *)(uintptr_t)va, size * nents);
}

static struct pan_kmod_dev *
kbase_kmod_dev_create(int fd, uint32_t flags,
                      UNUSED const struct pan_kmod_driver *drv_info,
                      const struct pan_kmod_allocator *allocator)
{
   /* Version handshake.  This must be the very first ioctl on the fd; all
    * other ioctls return -EPERM until it succeeds.  The CSF flavour
    * (arch >= 10: G610/G710/...) uses ioctl nr 52, the JM flavour
    * (arch <= 9) uses nr 0 — and each flavour rejects the other's number
    * with -EPERM, which is what makes this probe reliable.  We pass 0.0 and
    * let the kernel report the version it implements (CSF: 1.x, JM: 11.x,
    * legacy Midgard: 3.x). */
   struct kbase_ioctl_version_check ver = { 0 };
   bool is_csf = false;

   if (ioctl(fd, KBASE_IOCTL_VERSION_CHECK_CSF, &ver) == 0) {
      is_csf = true;
   } else if (ioctl(fd, KBASE_IOCTL_VERSION_CHECK_JM, &ver) == 0) {
      is_csf = false;

      if (ver.major < 11) {
         mesa_loge("kbase: legacy JM driver version %d.%d not supported "
                   "(need >= 11.0)", ver.major, ver.minor);
         return NULL;
      }
   } else {
      /* Not a usable kbase fd (or a device node we can't handshake with).
       * This is an expected outcome when probing device nodes, so keep it
       * quiet. */
      mesa_logd("kbase: version handshake rejected: %s", strerror(errno));
      return NULL;
   }

   mesa_logd("kbase: %s driver, uAPI version %d.%d",
             is_csf ? "CSF" : "JM", ver.major, ver.minor);

   /* Set context creation flags.  Zero for maximum compatibility; this also
    * creates the kernel-side context. */
   struct kbase_ioctl_set_flags set_flags = { .create_flags = 0 };
   if (ioctl(fd, KBASE_IOCTL_SET_FLAGS, &set_flags)) {
      mesa_loge("kbase: KBASE_IOCTL_SET_FLAGS failed: %s", strerror(errno));
      return NULL;
   }

   /* Map the tracking page.  The kernel requires this before any memory
    * operation. */
   void *tracking_page = mmap(NULL, 4096, PROT_NONE, MAP_SHARED, fd,
                              BASE_MEM_MAP_TRACKING_HANDLE);
   if (tracking_page == MAP_FAILED) {
      mesa_loge("kbase: mmap(BASE_MEM_MAP_TRACKING_HANDLE) failed: %s",
                strerror(errno));
      return NULL;
   }

   /* Fetch GPU properties. */
   size_t props_size = 0;
   uint8_t *props_buf = kbase_get_gpuprops(fd, &props_size);
   if (!props_buf) {
      mesa_loge("kbase: failed to read GPU properties");
      goto err_unmap_tracking;
   }

   /* Initialise the JIT allocator.  This must happen before any allocation
    * is made: besides setting up JIT, on 64-bit clients this is what carves
    * the CUSTOM_VA zone out of the top of the SAME_VA zone
    * (kbase_region_tracker_init_jit_64) — and kernel-internal allocations
    * such as tiler heap contexts/chunks come from that zone, so without it
    * KBASE_IOCTL_CS_TILER_HEAP_INIT fails with ENOMEM.  Parameters match
    * panfork's.  Failure is non-fatal for enumeration but breaks tiler
    * heaps, so warn. */
   struct kbase_ioctl_mem_jit_init jit_init = {
      .va_pages = 1ull << 25,
      .max_allocations = 255,
      .phys_pages = 1ull << 25,
   };
   if (ioctl(fd, KBASE_IOCTL_MEM_JIT_INIT, &jit_init)) {
      mesa_logw("kbase: KBASE_IOCTL_MEM_JIT_INIT failed: %s "
                "(tiler heap creation will not work)", strerror(errno));
   }

   /* Initialise the EXEC_VA zone so that GPU-executable allocations
    * (shader BOs) are possible.  4G of executable VA (0x100000 pages)
    * matches what panfork uses.  On CSF uAPI >= 1.9 the zone is set up
    * automatically and this is a no-op.  Failure is not fatal for
    * enumeration, but executable allocations will fail later, so warn. */
   struct kbase_ioctl_mem_exec_init exec_init = { .va_pages = 0x100000 };
   if (ioctl(fd, KBASE_IOCTL_MEM_EXEC_INIT, &exec_init)) {
      mesa_logw("kbase: KBASE_IOCTL_MEM_EXEC_INIT failed: %s "
                "(executable BO allocation will not work)", strerror(errno));
   }

   struct kbase_kmod_dev *kbase_dev =
      pan_kmod_alloc(allocator, sizeof(*kbase_dev));
   if (!kbase_dev) {
      mesa_loge("kbase: failed to allocate kbase_kmod_dev");
      free(props_buf);
      goto err_unmap_tracking;
   }

   /* Report the kernel uAPI version from the handshake (the caller can't
    * use drmGetVersion() on a kbase fd, so drv_info is either NULL or a
    * zeroed fallback). */
   struct pan_kmod_driver kbase_drv = {
      .version = { .major = ver.major, .minor = ver.minor },
   };

   /* kbase traditionally routes cached BO synchronization through
    * KBASE_IOCTL_MEM_SYNC.  When the architecture exposes userspace cache
    * maintenance, the generic kmod layer issues the same range operations
    * directly and batches one barrier per submit.  This removes dozens of
    * ioctls per second on G710.  PANVK_KBASE_USER_CACHE_SYNC=0 keeps the
    * kernel path as a compatibility override; architectures without cache
    * ops fall back automatically. */
   const char *user_cache_sync = getenv("PANVK_KBASE_USER_CACHE_SYNC");
   if (user_cache_sync && !strcmp(user_cache_sync, "0"))
      flags |= PAN_KMOD_DEV_FLAG_MMAP_SYNC_THROUGH_KERNEL;

   pan_kmod_dev_init(&kbase_dev->base, fd, flags, &kbase_drv,
                     &kbase_kmod_ops, allocator);

   kbase_dev->is_csf = is_csf;
   kbase_dev->tracking_page = tracking_page;
   kbase_dev->next_handle = 1;
   kbase_dev->dma_heap_fd = -1;
   kbase_dev->kcpu.fence_fd = -1;
   simple_mtx_init(&kbase_dev->kcpu.lock, mtx_plain);

   if (is_csf && kbase_query_csif_info(fd, &kbase_dev->csif_info)) {
      mesa_loge("kbase: failed to query the CSF global interface");
      free(props_buf);
      munmap(tracking_page, 4096);
      kbase_dev->base.flags &= ~PAN_KMOD_DEV_FLAG_OWNS_FD;
      pan_kmod_dev_cleanup(&kbase_dev->base);
      simple_mtx_destroy(&kbase_dev->kcpu.lock);
      pan_kmod_free(allocator, kbase_dev);
      return NULL;
   }

   if (is_csf) {
      /* Map the CSF USER register page for LATEST_FLUSH reads.  Failure is
       * non-fatal: kbase_kmod_get_flush_id() then returns 0, which just
       * makes FLUSH_CACHE2 waits more conservative. */
      kbase_dev->user_reg_page =
         mmap(NULL, 4096, PROT_READ, MAP_SHARED, fd,
              BASEP_MEM_CSF_USER_REG_PAGE_HANDLE);
      if (kbase_dev->user_reg_page == MAP_FAILED) {
         mesa_logw("kbase: mmap of the CSF USER register page failed: %s",
                   strerror(errno));
         kbase_dev->user_reg_page = NULL;
      }
   }

   kbase_dev_query_props(kbase_dev, props_buf, props_size);
   free(props_buf);

   const char *dma_heap = getenv("PANVK_KBASE_DMA_HEAP");
   if (!dma_heap || !dma_heap[0])
      dma_heap = "/dev/dma_heap/system";

   kbase_dev->dma_heap_fd = open(dma_heap, O_RDONLY | O_CLOEXEC);
   if (kbase_dev->dma_heap_fd < 0)
      mesa_logd("kbase: dma-heap unavailable at %s: %s", dma_heap,
                strerror(errno));

   if (!kbase_dev->base.props.gpu_id) {
      mesa_loge("kbase: failed to determine GPU ID from properties");
      if (kbase_dev->dma_heap_fd >= 0)
         close(kbase_dev->dma_heap_fd);
      munmap(tracking_page, 4096);
      /* On failure the caller keeps ownership of the fd (it closes it on
       * NULL return), so don't let pan_kmod_dev_cleanup() close it too. */
      kbase_dev->base.flags &= ~PAN_KMOD_DEV_FLAG_OWNS_FD;
      pan_kmod_dev_cleanup(&kbase_dev->base);
      simple_mtx_destroy(&kbase_dev->kcpu.lock);
      pan_kmod_free(allocator, kbase_dev);
      return NULL;
   }

   if (is_csf && kbase_dev->csif_info.cs_reg_count != 96 &&
       kbase_dev->csif_info.cs_reg_count != 128) {
      uint32_t cs_reg_count =
         pan_arch(kbase_dev->base.props.gpu_id) >= 12 ? 128 : 96;
      mesa_logw("kbase: implausible CS work register count %u, using %u",
                kbase_dev->csif_info.cs_reg_count, cs_reg_count);
      kbase_dev->csif_info.cs_reg_count = cs_reg_count;
   }

   const char *kcpu_sync = getenv("PANVK_KBASE_KCPU_SYNC");
   /* Keep this path opt-in for now.  A KCPU CQS wait needs two enqueue
    * ioctls (shipping kernels accept one command per enqueue), which is a
    * net loss for the sub-millisecond waits common in lightweight scenes.
    * It remains useful for profiling long waits and as the building block
    * for future async WSI fence export. */
   if (is_csf && kcpu_sync && !strcmp(kcpu_sync, "1")) {
      struct kbase_ioctl_kcpu_queue_new create = { 0 };
      if (!ioctl(fd, KBASE_IOCTL_KCPU_QUEUE_CREATE, &create)) {
         kbase_dev->kcpu.id = create.id;
         kbase_dev->kcpu.valid = true;
         mesa_logd("kbase: created KCPU queue %u", create.id);
      } else {
         mesa_logd("kbase: KCPU queue unavailable: %s", strerror(errno));
      }
   }

   return &kbase_dev->base;

err_unmap_tracking:
   munmap(tracking_page, 4096);
   return NULL;
}

static void
kbase_kmod_dev_destroy(struct pan_kmod_dev *dev)
{
   struct kbase_kmod_dev *kbase_dev =
      container_of(dev, struct kbase_kmod_dev, base);

   simple_mtx_lock(&kbase_dev->kcpu.lock);
   if (kbase_dev->kcpu.fence_fd >= 0)
      close(kbase_dev->kcpu.fence_fd);
   if (kbase_dev->kcpu.valid) {
      struct kbase_ioctl_kcpu_queue_delete delete = {
         .id = kbase_dev->kcpu.id,
      };
      ioctl(dev->fd, KBASE_IOCTL_KCPU_QUEUE_DELETE, &delete);
   }
   simple_mtx_unlock(&kbase_dev->kcpu.lock);
   simple_mtx_destroy(&kbase_dev->kcpu.lock);

   if (kbase_dev->user_reg_page)
      munmap(kbase_dev->user_reg_page, 4096);

   if (kbase_dev->tracking_page)
      munmap(kbase_dev->tracking_page, 4096);

   if (kbase_dev->dma_heap_fd >= 0)
      close(kbase_dev->dma_heap_fd);

   pan_kmod_dev_cleanup(dev);
   pan_kmod_free(dev->allocator, kbase_dev);
}

/* -------------------------------------------------------------------------
 * VA range query
 *
 * kbase supports up to 48-bit VAs on Valhall; on JM GPUs the VA space is
 * 32-bit (mmu_features.va_bits = 32). Reserve the bottom 32 MB as panfrost
 * does.
 * ---------------------------------------------------------------------- */

#define KBASE_KMOD_VA_RESERVE 0x2000000ull

static struct pan_kmod_va_range
kbase_kmod_dev_query_user_va_range(const struct pan_kmod_dev *dev)
{
   uint8_t va_bits = MMU_FEATURES_VA_BITS(dev->props.mmu_features);
   if (va_bits < 32)
      va_bits = 32;

   uint64_t end = va_bits == 32 ? (1ull << 32) : (1ull << (va_bits - 1));

   return (struct pan_kmod_va_range){
      .start = KBASE_KMOD_VA_RESERVE,
      .size  = end - KBASE_KMOD_VA_RESERVE,
   };
}

/* -------------------------------------------------------------------------
 * Buffer object allocation / free
 * ---------------------------------------------------------------------- */

static uint64_t
to_kbase_mem_flags(uint32_t kmod_flags)
{
   uint64_t flags = BASE_MEM_PROT_GPU_RD | BASE_MEM_PROT_GPU_WR |
                    BASE_MEM_PROT_CPU_RD | BASE_MEM_PROT_CPU_WR;

   /* Keep GPU cores coherent with each other (panfork does the same). */
   flags |= BASE_MEM_COHERENT_LOCAL;

   if (kmod_flags & PAN_KMOD_BO_FLAG_EXECUTABLE) {
      /* The kernel rejects GPU_EX|GPU_WR (W^X), and executable regions
       * must come from the EXEC_VA zone rather than SAME_VA. */
      flags |= BASE_MEM_PROT_GPU_EX;
      flags &= ~BASE_MEM_PROT_GPU_WR;
   } else {
      /* The kernel forces SAME_VA on non-executable allocations from
       * 64-bit clients anyway; request it explicitly so the behavior is
       * uniform. */
      flags |= BASE_MEM_SAME_VA;
   }

   if (kmod_flags & PAN_KMOD_BO_FLAG_GPU_UNCACHED)
      flags |= BASE_MEM_UNCACHED_GPU;

   if (kmod_flags & PAN_KMOD_BO_FLAG_WB_MMAP)
      flags |= BASE_MEM_CACHED_CPU;

   if (kmod_flags & PAN_KMOD_BO_FLAG_IO_COHERENT)
      flags |= BASE_MEM_COHERENT_SYSTEM;

   if (kmod_flags & PAN_KMOD_BO_FLAG_ALLOC_ON_FAULT)
      flags |= BASE_MEM_GROW_ON_GPF;

   if (kmod_flags & PAN_KMOD_BO_FLAG_CSF_EVENT) {
      flags |= BASE_MEM_CSF_EVENT;
      flags &= ~BASE_MEM_COHERENT_LOCAL;
   }

   return flags;
}

static struct pan_kmod_bo *
kbase_kmod_import_dmabuf(struct pan_kmod_dev *dev,
                         struct pan_kmod_vm *exclusive_vm, int fd,
                         uint64_t size, uint32_t kmod_flags,
                         bool external_import)
{
   struct kbase_kmod_dev *kbase_dev =
      container_of(dev, struct kbase_kmod_dev, base);
   const uint64_t page_size = 4096;
   struct kbase_kmod_bo *kbase_bo =
      pan_kmod_dev_alloc(dev, sizeof(*kbase_bo));
   if (!kbase_bo)
      return NULL;

   kbase_bo->dmabuf_fd = fcntl(fd, F_DUPFD_CLOEXEC, 3);
   if (kbase_bo->dmabuf_fd < 0) {
      mesa_loge("kbase: failed to duplicate dma-buf: %s", strerror(errno));
      goto err_free_bo;
   }

   uint64_t import_flags =
      BASE_MEM_PROT_CPU_RD | BASE_MEM_PROT_CPU_WR |
      BASE_MEM_PROT_GPU_RD | BASE_MEM_PROT_GPU_WR |
      BASE_MEM_IMPORT_SHARED | BASE_MEM_COHERENT_SYSTEM;

   if (kmod_flags & PAN_KMOD_BO_FLAG_GPU_UNCACHED)
      import_flags |= BASE_MEM_UNCACHED_GPU;
   if (kmod_flags & PAN_KMOD_BO_FLAG_WB_MMAP)
      import_flags |= BASE_MEM_CACHED_CPU;

   /* Bring-up escape hatch: PANVK_KBASE_IMPORT_CLEAR/SET adjust the
    * MEM_IMPORT flag word (hex masks) to probe DDK-specific import
    * behavior without rebuilding. */
   const char *clear_env = getenv("PANVK_KBASE_IMPORT_CLEAR");
   const char *set_env = getenv("PANVK_KBASE_IMPORT_SET");
   if (clear_env && clear_env[0])
      import_flags &= ~strtoull(clear_env, NULL, 0);
   if (set_env && set_env[0])
      import_flags |= strtoull(set_env, NULL, 0);

   int import_fd = kbase_bo->dmabuf_fd;
   union kbase_ioctl_mem_import req = {
      .in = {
         .flags = import_flags,
         .phandle = (uintptr_t)&import_fd,
         .type = BASE_MEM_IMPORT_TYPE_UMM,
      },
   };

   if (ioctl(dev->fd, KBASE_IOCTL_MEM_IMPORT, &req)) {
      mesa_loge("kbase: KBASE_IOCTL_MEM_IMPORT failed: %s", strerror(errno));
      goto err_close_dmabuf;
   }

   const uint64_t bo_size = req.out.va_pages * page_size;
   /* SAME_VA and NEED_MMAP are different contracts (UAPI: SAME_VA regions
    * return a mmap cookie and the mmap return address becomes both VAs;
    * NEED_MMAP regions return a real GPU VA with a separate CPU mapping).
    * Older DDKs report SAME_VA for dma-heap imports; this DDK (MediaTek,
    * CSF uAPI 1.21) reports NEED_MMAP, so the cases must not be lumped. */
   kbase_bo->same_va =
      (req.out.flags & (BASE_MEM_SAME_VA | BASE_MEM_NEED_MMAP)) != 0;
   kbase_bo->cpu_gpu_coherent =
      (req.out.flags & BASE_MEM_COHERENT_SYSTEM) != 0;

   kbase_bo->gpu_mapping =
      mmap(NULL, bo_size, PROT_READ | PROT_WRITE, MAP_SHARED, dev->fd,
           req.out.gpu_va);
   if (kbase_bo->gpu_mapping == MAP_FAILED) {
      mesa_loge("kbase: mmap of imported dma-buf failed: %s",
                strerror(errno));
      kbase_bo->gpu_mapping = NULL;
      struct kbase_ioctl_mem_free free_req = { .gpu_addr = req.out.gpu_va };
      ioctl(dev->fd, KBASE_IOCTL_MEM_FREE, &free_req);
      goto err_close_dmabuf;
   }

   if (!(kmod_flags & PAN_KMOD_BO_FLAG_NO_MMAP)) {
      kbase_bo->cpu_ptr =
         mmap(NULL, bo_size, PROT_READ | PROT_WRITE, MAP_SHARED,
              kbase_bo->dmabuf_fd, 0);
      if (kbase_bo->cpu_ptr == MAP_FAILED) {
         mesa_loge("kbase: CPU mmap of imported dma-buf failed: %s",
                   strerror(errno));
         kbase_bo->cpu_ptr = NULL;
         goto err_unmap_gpu;
      }
      kbase_bo->owns_cpu_mapping = true;
   }

   kbase_bo->gpu_va = (uintptr_t)kbase_bo->gpu_mapping;
   uint32_t handle = p_atomic_inc_return(&kbase_dev->next_handle);
   uint32_t flags = kmod_flags;
   if (external_import)
      flags |= PAN_KMOD_BO_FLAG_IMPORTED;

   pan_kmod_bo_init(&kbase_bo->base, dev, exclusive_vm, bo_size, flags,
                    handle);
   mesa_logi("kbase_kmod_bo_alloc_dmabuf: succeeded for %d, bo_size=%lu, handle=%u", kbase_bo->dmabuf_fd, bo_size, handle);
   mesa_logi("kbase: import flags=0x%llx -> va=0x%llx pages=%llu outflags=0x%llx",
             (unsigned long long)import_flags,
             (unsigned long long)req.out.gpu_va,
             (unsigned long long)req.out.va_pages,
             (unsigned long long)req.out.flags);
   return &kbase_bo->base;

err_unmap_gpu:
   munmap(kbase_bo->gpu_mapping, bo_size);
   if (!kbase_bo->same_va) {
      struct kbase_ioctl_mem_free free_req = { .gpu_addr = req.out.gpu_va };
      ioctl(dev->fd, KBASE_IOCTL_MEM_FREE, &free_req);
   }
err_close_dmabuf:
   close(kbase_bo->dmabuf_fd);
err_free_bo:
   pan_kmod_dev_free(dev, kbase_bo);
   return NULL;
}

static struct pan_kmod_bo *
kbase_kmod_bo_alloc_dmabuf(struct pan_kmod_dev *dev, uint64_t size,
                           uint32_t kmod_flags)
{
   struct kbase_kmod_dev *kbase_dev =
      container_of(dev, struct kbase_kmod_dev, base);
   const uint64_t page_size = 4096;
   struct dma_heap_allocation_data alloc = {
      .len = ALIGN_POT(size, page_size),
      .fd_flags = O_RDWR | O_CLOEXEC,
   };

   if (ioctl(kbase_dev->dma_heap_fd, DMA_HEAP_IOCTL_ALLOC, &alloc)) {
      mesa_loge("kbase: DMA_HEAP_IOCTL_ALLOC failed: %s", strerror(errno));
      return NULL;
   }

   struct pan_kmod_bo *bo = kbase_kmod_import_dmabuf(
      dev, NULL, alloc.fd, alloc.len, kmod_flags, false);
   close(alloc.fd);
   return bo;
}

static struct pan_kmod_bo *
kbase_kmod_bo_alloc(struct pan_kmod_dev *dev,
                    struct pan_kmod_vm *exclusive_vm, uint64_t size,
                    uint32_t kmod_flags)
{
   struct kbase_kmod_dev *kbase_dev =
      container_of(dev, struct kbase_kmod_dev, base);

   if (!exclusive_vm && kbase_dev->dma_heap_fd >= 0 &&
       !(kmod_flags & (PAN_KMOD_BO_FLAG_EXECUTABLE |
                       PAN_KMOD_BO_FLAG_ALLOC_ON_FAULT |
                       PAN_KMOD_BO_FLAG_CSF_EVENT)))
      return kbase_kmod_bo_alloc_dmabuf(dev, size, kmod_flags);

   const uint64_t page_size = 4096;
   uint64_t va_pages = (size + page_size - 1) / page_size;

   struct kbase_kmod_bo *kbase_bo =
      pan_kmod_dev_alloc(dev, sizeof(*kbase_bo));
   if (!kbase_bo) {
      mesa_loge("kbase: failed to allocate kbase_kmod_bo");
      return NULL;
   }
   kbase_bo->dmabuf_fd = -1;
   kbase_bo->owns_cpu_mapping = true;

   uint64_t commit_pages = va_pages;
   uint64_t extension = 0;
   uint64_t alloc_flags = to_kbase_mem_flags(kmod_flags);
   uint64_t alloc_gpu_va;

   if (kmod_flags & PAN_KMOD_BO_FLAG_ALLOC_ON_FAULT) {
      /* Growable region: nothing committed up-front, grown in 2 MB
       * increments on GPU page fault (matches panfork's heap setup). */
      commit_pages = 0;
      extension = (2 * 1024 * 1024) / page_size;
   }

   if (kbase_dev->is_csf &&
       pan_kmod_driver_version_at_least(&dev->driver, 1, 9)) {
      /* Match current Arm userspace on modern CSF kernels.  Besides keeping
       * the allocation ABI aligned with kbase, this leaves room for fixed-VA
       * and future allocation parameters without another backend split. */
      union kbase_ioctl_mem_alloc_ex req = {
         .in = {
            .va_pages = va_pages,
            .commit_pages = commit_pages,
            .extension = extension,
            .flags = alloc_flags,
         },
      };

      if (ioctl(dev->fd, KBASE_IOCTL_MEM_ALLOC_EX, &req)) {
         mesa_loge("kbase: KBASE_IOCTL_MEM_ALLOC_EX failed: %s",
                   strerror(errno));
         goto err_free_bo;
      }

      alloc_flags = req.out.flags;
      alloc_gpu_va = req.out.gpu_va;
   } else {
      union kbase_ioctl_mem_alloc req = {
         .in = {
            .va_pages = va_pages,
            .commit_pages = commit_pages,
            .extension = extension,
            .flags = alloc_flags,
         },
      };

      if (ioctl(dev->fd, KBASE_IOCTL_MEM_ALLOC, &req)) {
         mesa_loge("kbase: KBASE_IOCTL_MEM_ALLOC failed: %s", strerror(errno));
         goto err_free_bo;
      }

      alloc_flags = req.out.flags;
      alloc_gpu_va = req.out.gpu_va;
   }

   kbase_bo->same_va = (alloc_flags & BASE_MEM_SAME_VA) != 0;
   kbase_bo->cpu_gpu_coherent =
      (alloc_flags & BASE_MEM_COHERENT_SYSTEM) != 0;

   /* Establish the CPU mapping right away:
    *  - for SAME_VA regions out.gpu_va is a cookie, and this mmap() is what
    *    actually creates the region mapping — the returned CPU address IS
    *    the GPU VA;
    *  - for EXEC_VA-zone regions out.gpu_va is already a real GPU VA that
    *    doubles as the mmap offset.
    * The mapping is kept for the whole BO lifetime (see bo_mmap/bo_munmap).
    */
   void *cpu_ptr = mmap(NULL, va_pages * page_size, PROT_READ | PROT_WRITE,
                        MAP_SHARED, dev->fd, alloc_gpu_va);
   if (cpu_ptr == MAP_FAILED) {
      mesa_loge("kbase: mmap of BO (cookie/VA 0x%" PRIx64 ", size %" PRIu64
                ") failed: %s", alloc_gpu_va,
                va_pages * page_size, strerror(errno));

      /* MEM_FREE works on both real VAs and pending cookies. */
      struct kbase_ioctl_mem_free free_req = { .gpu_addr = alloc_gpu_va };
      ioctl(dev->fd, KBASE_IOCTL_MEM_FREE, &free_req);
      goto err_free_bo;
   }

   kbase_bo->cpu_ptr = cpu_ptr;
   kbase_bo->gpu_mapping = cpu_ptr;
   kbase_bo->gpu_va = kbase_bo->same_va ? (uintptr_t)cpu_ptr : alloc_gpu_va;


   /* Allocate a unique u32 handle for the pan_kmod handle_to_bo table. */
   uint32_t handle = p_atomic_inc_return(&kbase_dev->next_handle);

   pan_kmod_bo_init(&kbase_bo->base, dev, exclusive_vm,
                    va_pages * page_size, kmod_flags, handle);
   return &kbase_bo->base;

err_free_bo:
   pan_kmod_dev_free(dev, kbase_bo);
   return NULL;
}

static void
kbase_kmod_bo_free(struct pan_kmod_bo *bo)
{
   struct kbase_kmod_bo *kbase_bo =
      container_of(bo, struct kbase_kmod_bo, base);

   pan_kmod_bo_cleanup(bo);

   /* For SAME_VA regions, munmap() alone tears the whole region down
    * (free-on-close); a MEM_FREE afterwards would hit a stale VA.  For
    * zone regions (EXEC_VA), munmap() only drops the CPU mapping and the
    * region must be freed explicitly. */
   if (kbase_bo->owns_cpu_mapping && kbase_bo->cpu_ptr &&
       kbase_bo->cpu_ptr != kbase_bo->gpu_mapping)
      munmap(kbase_bo->cpu_ptr, bo->size);

   if (kbase_bo->gpu_mapping)
      munmap(kbase_bo->gpu_mapping, bo->size);

   if (!kbase_bo->same_va) {
      struct kbase_ioctl_mem_free req = { .gpu_addr = kbase_bo->gpu_va };
      if (ioctl(bo->dev->fd, KBASE_IOCTL_MEM_FREE, &req))
         mesa_loge("kbase: KBASE_IOCTL_MEM_FREE failed: %s", strerror(errno));
   }

   if (kbase_bo->dmabuf_fd >= 0)
      close(kbase_bo->dmabuf_fd);

   pan_kmod_dev_free(bo->dev, kbase_bo);
}

/*
 * dma-buf import is not yet implemented: pan_kmod_bo_import() first calls
 * drmPrimeFDToHandle() which requires a DRM fd.  It will fail gracefully
 * (returns NULL) on a kbase fd, so callers get NULL without a crash.
 * A full implementation would call KBASE_IOCTL_MEM_IMPORT here.
 */
static struct pan_kmod_bo *
kbase_kmod_bo_import(struct pan_kmod_dev *dev, uint32_t handle, uint64_t size)
{
   mesa_loge("kbase: bo_import not yet implemented "
             "(dma-buf import requires KBASE_IOCTL_MEM_IMPORT)");
   errno = ENOSYS;
   return NULL;
}

static struct pan_kmod_bo *
kbase_kmod_bo_import_fd(struct pan_kmod_dev *dev, int fd, uint64_t size)
{
   return kbase_kmod_import_dmabuf(dev, NULL, fd, size, 0, true);
}

static int
kbase_kmod_bo_export_fd(struct pan_kmod_bo *bo)
{
   struct kbase_kmod_bo *kbase_bo =
      container_of(bo, struct kbase_kmod_bo, base);

   if (kbase_bo->dmabuf_fd < 0) {
      errno = ENOSYS;
      return -1;
   }

   return fcntl(kbase_bo->dmabuf_fd, F_DUPFD_CLOEXEC, 3);
}

/* The GPU VA doubles as the mmap() file offset in kbase, but BOs are mapped
 * once at allocation time and bo_mmap below returns the cached mapping, so
 * this is only kept as a fallback. */
static off_t
kbase_kmod_bo_get_mmap_offset(struct pan_kmod_bo *bo)
{
   struct kbase_kmod_bo *kbase_bo =
      container_of(bo, struct kbase_kmod_bo, base);
   return (off_t)kbase_bo->gpu_va;
}

/* Return the CPU mapping established at allocation time.  A SAME_VA region
 * has exactly one CPU mapping and kbase's get_unmapped_area rejects both
 * MAP_FIXED and mremap(MREMAP_FIXED) (measured on G615: EINVAL).  A
 * caller-chosen address (VK_EXT_map_memory_placed, 32-bit WoW64 needs
 * < 4 GiB) therefore only works for dma-buf backed BOs: the dma-buf is mapped
 * a second time at that address, sharing pages with the GPU (no copy, no
 * sync).  panvk allocates host-visible memory from the dma-heap when the app
 * enables memoryMapPlaced (patch 091).
 * ponytail: without /dev/dma_heap placed maps fail (ENOTSUP); an anonymous
 * shadow copy needs dirty tracking to be both correct and fast. */
static void *
kbase_kmod_bo_mmap(struct pan_kmod_bo *bo, UNUSED int prot, UNUSED int flags,
                   void *host_addr)
{
   struct kbase_kmod_bo *kbase_bo =
      container_of(bo, struct kbase_kmod_bo, base);

   if (!kbase_bo->cpu_ptr) {
      errno = EINVAL;
      return MAP_FAILED;
   }

   if (host_addr == NULL || host_addr == kbase_bo->cpu_ptr)
      return kbase_bo->cpu_ptr;

   if (kbase_bo->dmabuf_fd < 0) {
      mesa_loge("kbase: placed map of a non-dma-buf BO is not supported");
      errno = ENOTSUP;
      return MAP_FAILED;
   }

   /* MAP_FIXED is the VK_EXT_map_memory_placed contract: the range is the
    * caller's (usually a PROT_NONE reservation). */
   void *p = mmap(host_addr, bo->size, PROT_READ | PROT_WRITE,
                  MAP_SHARED | MAP_FIXED, kbase_bo->dmabuf_fd, 0);
   if (p == MAP_FAILED)
      mesa_loge("kbase: placed dma-buf mmap at %p failed: %s", host_addr,
                strerror(errno));
   return p;
}

/* Normally the mapping belongs to the BO and lives until bo_free: unmapping
 * a SAME_VA region would free its GPU mapping too.  Only a placed dma-buf
 * alias (any other address) is unmapped. */
static int
kbase_kmod_bo_munmap(struct pan_kmod_bo *bo, void *host_addr, size_t size)
{
   struct kbase_kmod_bo *kbase_bo =
      container_of(bo, struct kbase_kmod_bo, base);

   if (host_addr && host_addr != kbase_bo->cpu_ptr &&
       host_addr != kbase_bo->gpu_mapping)
      return munmap(host_addr, size);
   return 0;
}

/* kbase does not expose per-BO fence objects.
 *
 * Returning true here is safe for non-shared BOs that have an exclusive_vm
 * (the common case for compute/render work) because the GPU is serialised by
 * the queue-submission path before the CPU touches the buffer.  For shared /
 * exported BOs proper inter-process synchronisation must be handled at a
 * higher level (e.g. via sync_file / Android fence).
 *
 * A full implementation would use KBASE_IOCTL_KCPU_QUEUE_ENQUEUE with a
 * fence-wait operation to block until the GPU has finished with the BO. */
static bool
kbase_kmod_bo_wait(struct pan_kmod_bo *bo, int64_t timeout_ns,
                   bool for_read_only_access)
{
   return true;
}

static int
kbase_kmod_flush_bo_map_syncs(struct pan_kmod_dev *dev)
{
   util_dynarray_foreach(&dev->pending_bo_syncs.array,
                         struct pan_kmod_deferred_bo_sync, sync) {
      struct kbase_kmod_bo *kbase_bo =
         container_of(sync->bo, struct kbase_kmod_bo, base);

      const bool flush = sync->type == PAN_KMOD_BO_SYNC_CPU_CACHE_FLUSH;

      /* System-coherent regions (dma-heap imports on DDKs that report
       * BASE_MEM_COHERENT_SYSTEM) need no MEM_SYNC; the ioctl rejects
       * them with EINVAL. */
      if (kbase_bo->cpu_gpu_coherent)
         continue;

      struct kbase_ioctl_mem_sync req = {
         .handle = kbase_bo->gpu_va,
         .user_addr = (uintptr_t)kbase_bo->cpu_ptr + sync->start,
         .size = sync->size,
         .type = flush ? BASE_SYNCSET_OP_MSYNC : BASE_SYNCSET_OP_CSYNC,
      };

      int ret = pan_kmod_ioctl(dev->fd, KBASE_IOCTL_MEM_SYNC, &req);
      if (ret) {
         mesa_loge("kbase: KBASE_IOCTL_MEM_SYNC failed: %s", strerror(errno));
         return -1;
      }
   }

   return 0;
}

/* Eviction hints — kbase does not expose a madvise ioctl in the userspace
 * API so these are no-ops. */
static void
kbase_kmod_bo_make_evictable(UNUSED struct pan_kmod_bo *bo)
{
}

static bool
kbase_kmod_bo_make_unevictable(UNUSED struct pan_kmod_bo *bo)
{
   return true;
}

/* -------------------------------------------------------------------------
 * VM (GPU address space) management
 *
 * kbase provides exactly one GPU address space per context and assigns all
 * VAs itself (SAME_VA: the CPU mapping address; EXEC_VA: kernel-chosen).
 * There is no kernel object to create/destroy, so the VM is pure
 * bookkeeping:
 *
 * vm_bind MAP: reports the GPU VA already assigned at allocation time.
 * vm_bind UNMAP: no-op; the unmap happens when the BO is freed.
 * ---------------------------------------------------------------------- */

static struct pan_kmod_vm *
kbase_kmod_vm_create(struct pan_kmod_dev *dev, uint32_t flags,
                     uint64_t va_start, uint64_t va_range)
{
   struct kbase_kmod_vm *kbase_vm =
      pan_kmod_dev_alloc(dev, sizeof(*kbase_vm));
   if (!kbase_vm) {
      mesa_loge("kbase: failed to allocate kbase_kmod_vm");
      return NULL;
   }

   pan_kmod_vm_init(&kbase_vm->base, dev, 0 /* no kernel handle */, flags);
   return &kbase_vm->base;
}

static void
kbase_kmod_vm_destroy(struct pan_kmod_vm *vm)
{
   struct kbase_kmod_vm *kbase_vm =
      container_of(vm, struct kbase_kmod_vm, base);

   pan_kmod_dev_free(vm->dev, kbase_vm);
}

static int
kbase_kmod_vm_bind(struct pan_kmod_vm *vm, enum pan_kmod_vm_op_mode mode,
                   struct pan_kmod_vm_op *ops, uint32_t op_count)
{
   if (mode == PAN_KMOD_VM_OP_MODE_ASYNC) {
      mesa_loge("kbase: PAN_KMOD_VM_OP_MODE_ASYNC not supported");
      return -1;
   }

   for (uint32_t i = 0; i < op_count; i++) {
      struct pan_kmod_vm_op *op = &ops[i];

      if (op->type == PAN_KMOD_VM_OP_TYPE_MAP) {
         struct kbase_kmod_bo *kbase_bo =
            container_of(op->map.bo, struct kbase_kmod_bo, base);
         uint64_t va = kbase_bo->gpu_va + op->map.bo_offset;

         if (op->va.start == PAN_KMOD_VM_MAP_AUTO_VA) {
            /* kbase assigned the VA at alloc time; report it back. */
            op->va.start = va;
         } else if (op->va.start != va) {
            /* Mapping at a caller-chosen address is impossible in kbase
             * (no vm_bind equivalent).  Fail loudly rather than letting
             * the caller use a VA the GPU doesn't know about. */
            mesa_loge("kbase: cannot map BO at explicit VA 0x%" PRIx64
                      " (kbase-assigned VA is 0x%" PRIx64 ")",
                      op->va.start, va);
            return -1;
         }
      } else if (op->type == PAN_KMOD_VM_OP_TYPE_UNMAP) {
         /* Unmap happens automatically when the BO is freed. */
      } else if (op->type == PAN_KMOD_VM_OP_TYPE_SYNC_ONLY) {
         /* No-op. */
      }
   }

   return 0;
}

static enum pan_kmod_vm_state
kbase_kmod_vm_query_state(struct pan_kmod_vm *vm)
{
   /* kbase does not expose a VM-fault query; assume usable. */
   return PAN_KMOD_VM_USABLE;
}

/* -------------------------------------------------------------------------
 * Timestamp
 * ---------------------------------------------------------------------- */

static uint64_t
kbase_kmod_query_timestamp(const struct pan_kmod_dev *dev)
{
   union kbase_ioctl_get_cpu_gpu_timeinfo req = {
      .in.request_flags = BASE_TIMEINFO_TIMESTAMP_FLAG,
   };

   if (ioctl(dev->fd, KBASE_IOCTL_GET_CPU_GPU_TIMEINFO, &req) == 0)
      return req.out.timestamp;

   return 0;
}

/* -------------------------------------------------------------------------
 * BO labelling (not available in the kbase uAPI, silently ignored)
 * ---------------------------------------------------------------------- */

static void
kbase_kmod_bo_set_label(UNUSED struct pan_kmod_dev *dev,
                        UNUSED struct pan_kmod_bo *bo,
                        UNUSED const char *label)
{
}

/* -------------------------------------------------------------------------
 * ops vtable
 * ---------------------------------------------------------------------- */

const struct pan_kmod_ops kbase_kmod_ops = {
   .dev_create             = kbase_kmod_dev_create,
   .dev_destroy            = kbase_kmod_dev_destroy,
   .dev_query_user_va_range = kbase_kmod_dev_query_user_va_range,
   .bo_alloc               = kbase_kmod_bo_alloc,
   .bo_free                = kbase_kmod_bo_free,
   .bo_import              = kbase_kmod_bo_import,
   .bo_import_fd           = kbase_kmod_bo_import_fd,
   .bo_export_fd           = kbase_kmod_bo_export_fd,
   .bo_get_mmap_offset     = kbase_kmod_bo_get_mmap_offset,
   .bo_mmap                = kbase_kmod_bo_mmap,
   .bo_munmap              = kbase_kmod_bo_munmap,
   .flush_bo_map_syncs     = kbase_kmod_flush_bo_map_syncs,
   .bo_wait                = kbase_kmod_bo_wait,
   .bo_make_evictable      = kbase_kmod_bo_make_evictable,
   .bo_make_unevictable    = kbase_kmod_bo_make_unevictable,
   .vm_create              = kbase_kmod_vm_create,
   .vm_destroy             = kbase_kmod_vm_destroy,
   .vm_bind                = kbase_kmod_vm_bind,
   .vm_query_state         = kbase_kmod_vm_query_state,
   .query_timestamp        = kbase_kmod_query_timestamp,
   .bo_set_label           = kbase_kmod_bo_set_label,
};
