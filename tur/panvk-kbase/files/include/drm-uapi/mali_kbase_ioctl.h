/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
/*
 * Copyright (C) 2010-2023 ARM Limited. All rights reserved.
 *
 * ARM Mali kbase kernel driver userspace API definitions.
 * Assembled from the Arm Bifrost/Valhall kbase uAPI headers
 * (mali_kbase_ioctl.h, mali_kbase_jm_ioctl.h, mali_kbase_csf_ioctl.h,
 * mali_base_kernel.h, mali_kbase_gpuprops.h), matching kernel driver
 * releases r32p0–r44p0.  Values cross-checked against the panfork
 * userspace driver and the Rockchip/Google shipping kernel sources.
 *
 * Note: the kbase driver comes in two flavours with partially different
 * ioctl numbering:
 *  - JM (Job Manager, Midgard/Bifrost/Valhall arch <= 9):
 *    VERSION_CHECK is ioctl nr 0, uAPI version 11.x.
 *  - CSF (Command Stream Frontend, Valhall arch >= 10, e.g. G610/G710):
 *    VERSION_CHECK is ioctl nr 52 (nr 0 is reserved and returns -EPERM),
 *    uAPI version 1.x.
 * All ioctls other than the flavour's VERSION_CHECK return -EPERM until
 * the VERSION_CHECK + SET_FLAGS handshake has completed.
 */

#pragma once

#include <linux/ioctl.h>
#include <linux/types.h>

#define KBASE_IOCTL_TYPE 0x80

/* -----------------------------------------------------------------------
 * Version handshake — must be the first ioctl on a fresh /dev/mali* fd.
 * Input is the version userspace was built against (may be zero); the
 * kernel writes back the version it implements and records it.
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_version_check {
   __u16 major;
   __u16 minor;
};
/* JM flavour (also accepted by ancient Midgard drivers, which report 3.x) */
#define KBASE_IOCTL_VERSION_CHECK_JM \
   _IOWR(KBASE_IOCTL_TYPE, 0, struct kbase_ioctl_version_check)
/* CSF flavour */
#define KBASE_IOCTL_VERSION_CHECK_CSF \
   _IOWR(KBASE_IOCTL_TYPE, 52, struct kbase_ioctl_version_check)

/* -----------------------------------------------------------------------
 * Set context-creation flags.  Second step of the handshake.
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_set_flags {
   __u32 create_flags;
};
#define BASE_CONTEXT_CREATE_FLAG_NONE               0
#define BASE_CONTEXT_CCTX_EMBEDDED                  ((__u32)1 << 0)
#define BASE_CONTEXT_SYSTEM_MONITOR_SUBMIT_DISABLED ((__u32)1 << 1)

#define KBASE_IOCTL_SET_FLAGS \
   _IOW(KBASE_IOCTL_TYPE, 1, struct kbase_ioctl_set_flags)

/* -----------------------------------------------------------------------
 * Job submission (JM GPUs only, arch <= 9).
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_job_submit {
   __u64 addr;
   __u32 nr_atoms;
   __u32 stride;
};
#define KBASE_IOCTL_JOB_SUBMIT \
   _IOW(KBASE_IOCTL_TYPE, 2, struct kbase_ioctl_job_submit)

/* -----------------------------------------------------------------------
 * Query GPU properties.
 * Call with size=0 to probe the blob length (returned as the positive
 * ioctl return value), then allocate and call again with buffer/size set.
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_get_gpuprops {
   __u64 buffer;
   __u32 size;
   __u32 flags;
};
#define KBASE_IOCTL_GET_GPUPROPS \
   _IOW(KBASE_IOCTL_TYPE, 3, struct kbase_ioctl_get_gpuprops)

/* GPU property keys used in the serialised blob returned by GET_GPUPROPS.
 * Each entry is encoded as:
 *   [ 4-byte little-endian header: (key << 2) | size_code ]  [ value ]
 *   size_code: 0 = u8, 1 = u16, 2 = u32, 3 = u64
 */
#define KBASE_GPUPROP_PRODUCT_ID                    1
#define KBASE_GPUPROP_VERSION_STATUS                2
#define KBASE_GPUPROP_MINOR_REVISION                3
#define KBASE_GPUPROP_MAJOR_REVISION                4
/* 5 previously used for GPU speed */
#define KBASE_GPUPROP_GPU_FREQ_KHZ_MAX              6
/* 7 previously used for minimum GPU speed */
#define KBASE_GPUPROP_LOG2_PROGRAM_COUNTER_SIZE     8
#define KBASE_GPUPROP_TEXTURE_FEATURES_0            9
#define KBASE_GPUPROP_TEXTURE_FEATURES_1            10
#define KBASE_GPUPROP_TEXTURE_FEATURES_2            11
#define KBASE_GPUPROP_GPU_AVAILABLE_MEMORY_SIZE     12
#define KBASE_GPUPROP_L2_LOG2_LINE_SIZE             13
#define KBASE_GPUPROP_L2_LOG2_CACHE_SIZE            14
#define KBASE_GPUPROP_L2_NUM_L2_SLICES              15
#define KBASE_GPUPROP_TILER_BIN_SIZE_BYTES          16
#define KBASE_GPUPROP_TILER_MAX_ACTIVE_LEVELS       17
#define KBASE_GPUPROP_MAX_THREADS                   18
#define KBASE_GPUPROP_MAX_WORKGROUP_SIZE            19
#define KBASE_GPUPROP_MAX_BARRIER_SIZE              20
#define KBASE_GPUPROP_MAX_REGISTERS                 21
#define KBASE_GPUPROP_MAX_TASK_QUEUE                22
#define KBASE_GPUPROP_MAX_THREAD_GROUP_SPLIT        23
#define KBASE_GPUPROP_IMPL_TECH                     24
#define KBASE_GPUPROP_RAW_SHADER_PRESENT            25
#define KBASE_GPUPROP_RAW_TILER_PRESENT             26
#define KBASE_GPUPROP_RAW_L2_PRESENT                27
#define KBASE_GPUPROP_RAW_STACK_PRESENT             28
#define KBASE_GPUPROP_RAW_L2_FEATURES               29
#define KBASE_GPUPROP_RAW_CORE_FEATURES             30
#define KBASE_GPUPROP_RAW_MEM_FEATURES              31
#define KBASE_GPUPROP_RAW_MMU_FEATURES              32
#define KBASE_GPUPROP_RAW_AS_PRESENT                33
#define KBASE_GPUPROP_RAW_JS_PRESENT                34
#define KBASE_GPUPROP_RAW_JS_FEATURES_0             35
/* JS_FEATURES_1..15 occupy keys 36..50 */
#define KBASE_GPUPROP_RAW_TILER_FEATURES            51
#define KBASE_GPUPROP_RAW_TEXTURE_FEATURES_0        52
#define KBASE_GPUPROP_RAW_TEXTURE_FEATURES_1        53
#define KBASE_GPUPROP_RAW_TEXTURE_FEATURES_2        54
#define KBASE_GPUPROP_RAW_GPU_ID                    55
#define KBASE_GPUPROP_RAW_THREAD_MAX_THREADS        56
#define KBASE_GPUPROP_RAW_THREAD_MAX_WORKGROUP_SIZE 57
#define KBASE_GPUPROP_RAW_THREAD_MAX_BARRIER_SIZE   58
#define KBASE_GPUPROP_RAW_THREAD_FEATURES           59
#define KBASE_GPUPROP_RAW_COHERENCY_MODE            60
#define KBASE_GPUPROP_COHERENCY_NUM_GROUPS          61
#define KBASE_GPUPROP_COHERENCY_NUM_CORE_GROUPS     62
#define KBASE_GPUPROP_COHERENCY_COHERENCY           63
#define KBASE_GPUPROP_COHERENCY_GROUP_0             64
/* COHERENCY_GROUP_1..15 occupy keys 65..79 */
#define KBASE_GPUPROP_TEXTURE_FEATURES_3            80
#define KBASE_GPUPROP_RAW_TEXTURE_FEATURES_3        81
#define KBASE_GPUPROP_NUM_EXEC_ENGINES              82
#define KBASE_GPUPROP_RAW_THREAD_TLS_ALLOC          83
#define KBASE_GPUPROP_TLS_ALLOC                     84
#define KBASE_GPUPROP_RAW_GPU_FEATURES              85

/* -----------------------------------------------------------------------
 * Memory allocation.
 *
 * For 64-bit clients the kernel forces BASE_MEM_SAME_VA on all allocations
 * that are not GPU-executable (EXEC_VA zone) or FIXED/FIXABLE.  For SAME_VA
 * allocations out.gpu_va is NOT a GPU address but a mmap cookie: mmap()-ing
 * the kbase fd at that offset establishes the mapping, and the CPU address
 * returned by mmap() becomes both the CPU and the GPU VA of the region.
 * Non-SAME_VA allocations return a real GPU VA which can also be used as
 * the mmap offset to obtain a CPU mapping.
 * ----------------------------------------------------------------------- */
union kbase_ioctl_mem_alloc {
   struct {
      __u64 va_pages;
      __u64 commit_pages;
      __u64 extension;
      __u64 flags;
   } in;
   struct {
      __u64 flags;
      __u64 gpu_va;
   } out;
};
#define KBASE_IOCTL_MEM_ALLOC \
   _IOWR(KBASE_IOCTL_TYPE, 5, union kbase_ioctl_mem_alloc)

/* CSF uAPI 1.9 replaced MEM_ALLOC with an extensible request.  The first
 * four input fields and the output overlay intentionally match the legacy
 * request; fixed_address is zero unless BASE_MEM_FIXED is requested. */
union kbase_ioctl_mem_alloc_ex {
   struct {
      __u64 va_pages;
      __u64 commit_pages;
      __u64 extension;
      __u64 flags;
      __u64 fixed_address;
      __u64 extra[3];
   } in;
   struct {
      __u64 flags;
      __u64 gpu_va;
   } out;
};
#define KBASE_IOCTL_MEM_ALLOC_EX \
   _IOWR(KBASE_IOCTL_TYPE, 59, union kbase_ioctl_mem_alloc_ex)

/* Memory allocation/import flags (base_mem_alloc_flags) */
#define BASE_MEM_PROT_CPU_RD              ((__u64)1 << 0)
#define BASE_MEM_PROT_CPU_WR              ((__u64)1 << 1)
#define BASE_MEM_PROT_GPU_RD              ((__u64)1 << 2)
#define BASE_MEM_PROT_GPU_WR              ((__u64)1 << 3)
#define BASE_MEM_PROT_GPU_EX              ((__u64)1 << 4)
#define BASE_MEM_GPU_VA_SAME_4GB_PAGE     ((__u64)1 << 6)
#define BASE_MEM_GROW_ON_GPF              ((__u64)1 << 9)
#define BASE_MEM_COHERENT_SYSTEM          ((__u64)1 << 10)
#define BASE_MEM_COHERENT_LOCAL           ((__u64)1 << 11)
#define BASE_MEM_CACHED_CPU               ((__u64)1 << 12)
#define BASE_MEM_SAME_VA                  ((__u64)1 << 13)
#define BASE_MEM_NEED_MMAP                ((__u64)1 << 14)
#define BASE_MEM_COHERENT_SYSTEM_REQUIRED ((__u64)1 << 15)
#define BASE_MEM_PROTECTED                ((__u64)1 << 16)
#define BASE_MEM_DONT_NEED                ((__u64)1 << 17)
#define BASE_MEM_IMPORT_SHARED            ((__u64)1 << 18)
#define BASE_MEM_CSF_EVENT                ((__u64)1 << 19) /* CSF only */
#define BASE_MEM_UNCACHED_GPU             ((__u64)1 << 21)
#define BASE_MEM_IMPORT_SYNC_ON_MAP_UNMAP ((__u64)1 << 26)
#define BASE_MEM_KERNEL_SYNC              ((__u64)1 << 28)

/* Special mmap offsets ("memory handles"), in bytes (4K page based) */
#define BASE_MEM_MAP_TRACKING_HANDLE          (3ull << 12)
#define BASEP_MEM_CSF_USER_REG_PAGE_HANDLE    (47ull << 12) /* CSF only */
#define BASEP_MEM_CSF_USER_IO_PAGES_HANDLE    (48ull << 12) /* CSF only */
#define BASE_MEM_COOKIE_BASE                  (64ull << 12)
#define BASE_MEM_FIRST_FREE_ADDRESS           ((64ull + 64ull) << 12)

/* -----------------------------------------------------------------------
 * Memory query — query properties of an existing allocation.
 * ----------------------------------------------------------------------- */
union kbase_ioctl_mem_query {
   struct {
      __u64 gpu_addr;
      __u64 query;
   } in;
   struct {
      __u64 value;
   } out;
};
#define KBASE_IOCTL_MEM_QUERY \
   _IOWR(KBASE_IOCTL_TYPE, 6, union kbase_ioctl_mem_query)

#define KBASE_MEM_QUERY_COMMIT_SIZE ((__u64)1)
#define KBASE_MEM_QUERY_VA_SIZE     ((__u64)2)
#define KBASE_MEM_QUERY_FLAGS       ((__u64)3)

/* -----------------------------------------------------------------------
 * Memory free.
 * For SAME_VA regions the region is also torn down when the CPU mapping
 * is munmap()ed (free-on-close), in which case MEM_FREE must not be called.
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_mem_free {
   __u64 gpu_addr;
};
#define KBASE_IOCTL_MEM_FREE \
   _IOW(KBASE_IOCTL_TYPE, 7, struct kbase_ioctl_mem_free)

/* -----------------------------------------------------------------------
 * Just-in-time memory allocator initialisation (modern >= 11.20 layout).
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_mem_jit_init {
   __u64 va_pages;
   __u8 max_allocations;
   __u8 trim_level;
   __u8 group_id;
   __u8 padding[5];
   __u64 phys_pages;
};
#define KBASE_IOCTL_MEM_JIT_INIT \
   _IOW(KBASE_IOCTL_TYPE, 14, struct kbase_ioctl_mem_jit_init)

/* -----------------------------------------------------------------------
 * CPU cache maintenance on a mapped region.
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_mem_sync {
   __u64 handle;
   __u64 user_addr;
   __u64 size;
   __u8 type;
   __u8 padding[7];
};
#define BASE_SYNCSET_OP_MSYNC 1 /* clean to memory */
#define BASE_SYNCSET_OP_CSYNC 2 /* invalidate from memory */

#define KBASE_IOCTL_MEM_SYNC \
   _IOW(KBASE_IOCTL_TYPE, 15, struct kbase_ioctl_mem_sync)

/* -----------------------------------------------------------------------
 * Memory commit — change the physical backing of a growable region.
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_mem_commit {
   __u64 gpu_addr;
   __u64 pages;
};
#define KBASE_IOCTL_MEM_COMMIT \
   _IOW(KBASE_IOCTL_TYPE, 20, struct kbase_ioctl_mem_commit)

/* -----------------------------------------------------------------------
 * Memory alias — create an alias of one or more existing regions.
 * ----------------------------------------------------------------------- */
struct base_mem_aliasing_info {
   __u64 handle;
   __u64 offset;
   __u64 length;
};
union kbase_ioctl_mem_alias {
   struct {
      __u64 flags;
      __u64 stride;
      __u64 nents;
      __u64 aliasing_info;
   } in;
   struct {
      __u64 flags;
      __u64 gpu_va;
      __u64 va_pages;
   } out;
};
#define KBASE_IOCTL_MEM_ALIAS \
   _IOWR(KBASE_IOCTL_TYPE, 21, union kbase_ioctl_mem_alias)

/* -----------------------------------------------------------------------
 * Memory import — map external memory (dma-buf, user pointer) on the GPU.
 * ----------------------------------------------------------------------- */
union kbase_ioctl_mem_import {
   struct {
      __u64 flags;
      __u64 phandle;
      __u32 type;
      __u32 padding;
   } in;
   struct {
      __u64 flags;
      __u64 gpu_va;
      __u64 va_pages;
   } out;
};
#define KBASE_IOCTL_MEM_IMPORT \
   _IOWR(KBASE_IOCTL_TYPE, 22, union kbase_ioctl_mem_import)

/* base_mem_import_type */
#define BASE_MEM_IMPORT_TYPE_INVALID     0
#define BASE_MEM_IMPORT_TYPE_UMM         2 /* dma-buf */
#define BASE_MEM_IMPORT_TYPE_USER_BUFFER 3

/* -----------------------------------------------------------------------
 * Initialise the EXEC_VA zone.  Must be called (once) before any
 * allocation with BASE_MEM_PROT_GPU_EX on 64-bit clients.
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_mem_exec_init {
   __u64 va_pages;
};
#define KBASE_IOCTL_MEM_EXEC_INIT \
   _IOW(KBASE_IOCTL_TYPE, 38, struct kbase_ioctl_mem_exec_init)

/* -----------------------------------------------------------------------
 * CSF command-stream submission interface (CSF flavour only).
 *
 * A CS queue is a ring buffer in GPU memory: REGISTER it, BIND it to a
 * queue group (returns a cookie to mmap the USER_IO pages), then submit
 * by writing instructions to the ring, updating CS_INSERT in the input
 * page and KICKing the scheduler.
 * ----------------------------------------------------------------------- */
struct kbase_ioctl_cs_queue_register {
   __u64 buffer_gpu_addr;
   __u32 buffer_size;
   __u8 priority;
   __u8 padding[3];
};
#define KBASE_IOCTL_CS_QUEUE_REGISTER \
   _IOW(KBASE_IOCTL_TYPE, 36, struct kbase_ioctl_cs_queue_register)

struct kbase_ioctl_cs_queue_kick {
   __u64 buffer_gpu_addr;
};
#define KBASE_IOCTL_CS_QUEUE_KICK \
   _IOW(KBASE_IOCTL_TYPE, 37, struct kbase_ioctl_cs_queue_kick)

union kbase_ioctl_cs_queue_bind {
   struct {
      __u64 buffer_gpu_addr;
      __u8 group_handle;
      __u8 csi_index;
      __u8 padding[6];
   } in;
   struct {
      __u64 mmap_handle;
   } out;
};
#define KBASE_IOCTL_CS_QUEUE_BIND \
   _IOWR(KBASE_IOCTL_TYPE, 39, union kbase_ioctl_cs_queue_bind)

struct kbase_ioctl_cs_queue_terminate {
   __u64 buffer_gpu_addr;
};
#define KBASE_IOCTL_CS_QUEUE_TERMINATE \
   _IOW(KBASE_IOCTL_TYPE, 41, struct kbase_ioctl_cs_queue_terminate)

/* Number of pages mmap()ed from the QUEUE_BIND cookie:
 * page 0: doorbell (write any u32 to ring),
 * page 1: input page (CS_INSERT at 0x0, CS_EXTRACT_INIT at 0x8),
 * page 2: output page (CS_EXTRACT at 0x0, CS_ACTIVE at 0x8). */
#define BASEP_QUEUE_NR_MMAP_USER_PAGES 3

#define CS_USER_IO_INPUT_CS_INSERT       0x0000 /* u64, page 1 */
#define CS_USER_IO_INPUT_CS_EXTRACT_INIT 0x0008 /* u64, page 1 */
#define CS_USER_IO_OUTPUT_CS_EXTRACT     0x0000 /* u64, page 2 */
#define CS_USER_IO_OUTPUT_CS_ACTIVE      0x0008 /* u32, page 2 */

/* The USER register page (BASEP_MEM_CSF_USER_REG_PAGE_HANDLE mmap)
 * exposes LATEST_FLUSH at offset 0. */
#define CS_USER_REG_LATEST_FLUSH 0x0000 /* u32 */

union kbase_ioctl_cs_queue_group_create_1_6 {
   struct {
      __u64 tiler_mask;
      __u64 fragment_mask;
      __u64 compute_mask;
      __u8 cs_min;
      __u8 priority;
      __u8 tiler_max;
      __u8 fragment_max;
      __u8 compute_max;
      __u8 padding[3];
   } in;
   struct {
      __u8 group_handle;
      __u8 padding[3];
      __u32 group_uid;
   } out;
};
#define KBASE_IOCTL_CS_QUEUE_GROUP_CREATE_1_6 \
   _IOWR(KBASE_IOCTL_TYPE, 42, union kbase_ioctl_cs_queue_group_create_1_6)

/* Extended versions (uAPI >= 1.18). */
#define BASE_CSF_TILER_OOM_EXCEPTION_FLAG (1u << 0)
#define BASE_CSF_EXCEPTION_HANDLER_FLAGS_MASK \
   BASE_CSF_TILER_OOM_EXCEPTION_FLAG

union kbase_ioctl_cs_queue_group_create_1_18 {
   struct {
      __u64 tiler_mask;
      __u64 fragment_mask;
      __u64 compute_mask;
      __u8 cs_min;
      __u8 priority;
      __u8 tiler_max;
      __u8 fragment_max;
      __u8 compute_max;
      __u8 csi_handlers;
      __u8 padding[2];
      __u64 dvs_buf;
   } in;
   struct {
      __u8 group_handle;
      __u8 padding[3];
      __u32 group_uid;
   } out;
};
#define KBASE_IOCTL_CS_QUEUE_GROUP_CREATE_1_18 \
   _IOWR(KBASE_IOCTL_TYPE, 58, union kbase_ioctl_cs_queue_group_create_1_18)

/* Current queue-group create layout (uAPI >= 1.25).  The reserved tail keeps
 * the ioctl size stable as new fields are introduced. */
union kbase_ioctl_cs_queue_group_create {
   struct {
      __u64 tiler_mask;
      __u64 fragment_mask;
      __u64 compute_mask;
      __u8 cs_min;
      __u8 priority;
      __u8 tiler_max;
      __u8 fragment_max;
      __u8 compute_max;
      __u8 csi_handlers;
      __u8 neural_max;
      __u8 cs_fault_report_enable;
      __u64 dvs_buf;
      __u64 neural_mask;
      __u8 comp_pri_threshold;
      __u8 comp_pri_ratio;
      __u8 padding[62];
   } in;
   struct {
      __u8 group_handle;
      __u8 padding[3];
      __u32 group_uid;
   } out;
};
#define KBASE_IOCTL_CS_QUEUE_GROUP_CREATE \
   _IOWR(KBASE_IOCTL_TYPE, 58, union kbase_ioctl_cs_queue_group_create)

struct kbase_ioctl_cs_queue_group_term {
   __u8 group_handle;
   __u8 padding[7];
};
#define KBASE_IOCTL_CS_QUEUE_GROUP_TERMINATE \
   _IOW(KBASE_IOCTL_TYPE, 43, struct kbase_ioctl_cs_queue_group_term)

#define KBASE_IOCTL_CS_EVENT_SIGNAL \
   _IO(KBASE_IOCTL_TYPE, 44)

typedef __u8 base_kcpu_queue_id;

/* Kernel CPU queue commands.  These definitions mirror the public CSF
 * mali_base_csf_kernel.h ABI.  Keep the explicit padding: the kernel copies
 * an array of these objects directly from userspace. */
enum base_kcpu_command_type {
   BASE_KCPU_COMMAND_TYPE_FENCE_SIGNAL = 0,
   BASE_KCPU_COMMAND_TYPE_FENCE_WAIT = 1,
   BASE_KCPU_COMMAND_TYPE_CQS_WAIT = 2,
   BASE_KCPU_COMMAND_TYPE_CQS_SET = 3,
   BASE_KCPU_COMMAND_TYPE_CQS_WAIT_OPERATION = 4,
   BASE_KCPU_COMMAND_TYPE_CQS_SET_OPERATION = 5,
   BASE_KCPU_COMMAND_TYPE_MAP_IMPORT = 6,
   BASE_KCPU_COMMAND_TYPE_UNMAP_IMPORT = 7,
   BASE_KCPU_COMMAND_TYPE_UNMAP_IMPORT_FORCE = 8,
   BASE_KCPU_COMMAND_TYPE_JIT_ALLOC = 9,
   BASE_KCPU_COMMAND_TYPE_JIT_FREE = 10,
   BASE_KCPU_COMMAND_TYPE_GROUP_SUSPEND = 11,
   BASE_KCPU_COMMAND_TYPE_ERROR_BARRIER = 12,
};

#define BASEP_CQS_WAIT_OPERATION_LE 0
#define BASEP_CQS_WAIT_OPERATION_GT 1
#define BASEP_CQS_DATA_TYPE_U32 0
#define BASEP_CQS_DATA_TYPE_U64 1

struct base_fence {
   struct {
      __s32 fd;
      __s32 stream_fd;
   } basep;
};

struct base_kcpu_command_fence_info {
   __u64 fence;
};

struct base_cqs_wait_operation_info {
   __u64 addr;
   __u64 val;
   __u8 operation;
   __u8 data_type;
   __u8 padding[6];
};

struct base_kcpu_command_cqs_wait_operation_info {
   __u64 objs;
   __u32 nr_objs;
   __u32 inherit_err_flags;
};

struct base_kcpu_command {
   __u8 type;
   __u8 padding[7];
   union {
      struct base_kcpu_command_fence_info fence;
      struct base_kcpu_command_cqs_wait_operation_info cqs_wait_operation;
      __u64 padding[2];
   } info;
};

struct kbase_ioctl_kcpu_queue_new {
   base_kcpu_queue_id id;
   __u8 padding[7];
};
#define KBASE_IOCTL_KCPU_QUEUE_CREATE \
   _IOR(KBASE_IOCTL_TYPE, 45, struct kbase_ioctl_kcpu_queue_new)

struct kbase_ioctl_kcpu_queue_delete {
   base_kcpu_queue_id id;
   __u8 padding[7];
};
#define KBASE_IOCTL_KCPU_QUEUE_DELETE \
   _IOW(KBASE_IOCTL_TYPE, 46, struct kbase_ioctl_kcpu_queue_delete)

struct kbase_ioctl_kcpu_queue_enqueue {
   __u64 addr;
   __u32 nr_commands;
   base_kcpu_queue_id id;
   __u8 padding[3];
};
#define KBASE_IOCTL_KCPU_QUEUE_ENQUEUE \
   _IOW(KBASE_IOCTL_TYPE, 47, struct kbase_ioctl_kcpu_queue_enqueue)

union kbase_ioctl_cs_tiler_heap_init {
   struct {
      __u32 chunk_size;
      __u32 initial_chunks;
      __u32 max_chunks;
      __u16 target_in_flight;
      __u8 group_id;
      __u8 padding;
   } in;
   struct {
      __u64 gpu_heap_va;
      __u64 first_chunk_va;
   } out;
};
#define KBASE_IOCTL_CS_TILER_HEAP_INIT \
   _IOWR(KBASE_IOCTL_TYPE, 48, union kbase_ioctl_cs_tiler_heap_init)

struct kbase_ioctl_cs_tiler_heap_term {
   __u64 gpu_heap_va;
};
#define KBASE_IOCTL_CS_TILER_HEAP_TERM \
   _IOW(KBASE_IOCTL_TYPE, 49, struct kbase_ioctl_cs_tiler_heap_term)

/* -----------------------------------------------------------------------
 * CSF event notifications, delivered by read() on the device fd (CSF only).
 * ----------------------------------------------------------------------- */
struct base_gpu_queue_group_error_fatal_payload {
   __u64 sideband;
   __u32 status;
   __u8 padding[20];
};

struct base_gpu_queue_error_fatal_payload {
   __u64 sideband;
   __u32 status;
   __u8 csi_index;
   __u8 padding[6];
   __u8 has_extra;
   __u32 trace_id0;
   __u32 trace_id1;
   __u32 trace_task;
};

struct base_gpu_queue_error_fault_payload {
   __u64 sideband;
   __u32 status;
   __u8 csi_index;
   __u8 padding[6];
   __u8 has_extra;
   __u32 trace_id0;
   __u32 trace_id1;
   __u32 trace_task;
};

enum base_gpu_queue_group_error_type {
   BASE_GPU_QUEUE_GROUP_ERROR_FATAL = 0,
   BASE_GPU_QUEUE_GROUP_QUEUE_ERROR_FATAL,
   BASE_GPU_QUEUE_GROUP_ERROR_TIMEOUT,
   BASE_GPU_QUEUE_GROUP_ERROR_TILER_HEAP_OOM,
   BASE_GPU_QUEUE_GROUP_QUEUE_ERROR_FAULT,
   BASE_GPU_QUEUE_GROUP_ERROR_FATAL_COUNT,
};

struct base_gpu_queue_group_error {
   __u8 error_type;
   __u8 padding[7];
   union {
      struct base_gpu_queue_group_error_fatal_payload fatal_group;
      struct base_gpu_queue_error_fatal_payload fatal_queue;
      struct base_gpu_queue_error_fault_payload fault_queue;
   } payload;
};

enum base_csf_notification_type {
   BASE_CSF_NOTIFICATION_EVENT = 0,
   BASE_CSF_NOTIFICATION_GPU_QUEUE_GROUP_ERROR,
   BASE_CSF_NOTIFICATION_CPU_QUEUE_DUMP,
   BASE_CSF_NOTIFICATION_COUNT,
};

/* This structure is fixed at one 64-byte cache line. */
struct base_csf_notification {
   __u8 type;
   __u8 padding[7];
   union {
      struct {
         __u8 handle;
         __u8 padding[7];
         struct base_gpu_queue_group_error error;
      } csg_error;
      __u8 align[56];
   } payload;
};

/* -----------------------------------------------------------------------
 * CSF global interface query (CSF flavour only).
 * First call with max_group_num = max_total_stream_num = 0 to learn the
 * counts (returned in out), then call again with buffers.
 * ----------------------------------------------------------------------- */

/* Per-CS capabilities.  features bits: [7:0] work register count,
 * [15:8] scoreboard slot count. */
struct basep_cs_stream_control {
   __u32 features;
   __u32 padding;
};

/* Per-CSG capabilities. */
struct basep_cs_group_control {
   __u32 features;
   __u32 stream_num;
   __u32 suspend_size;
   __u32 padding;
};

union kbase_ioctl_cs_get_glb_iface {
   struct {
      __u32 max_group_num;
      __u32 max_total_stream_num;
      __u64 groups_ptr;
      __u64 streams_ptr;
   } in;
   struct {
      __u32 glb_version;
      __u32 features;
      __u32 group_num;
      __u32 prfcnt_size;
      __u32 total_stream_num;
      __u32 instr_features;
   } out;
};
#define KBASE_IOCTL_CS_GET_GLB_IFACE \
   _IOWR(KBASE_IOCTL_TYPE, 51, union kbase_ioctl_cs_get_glb_iface)

/* -----------------------------------------------------------------------
 * CPU–GPU time correlation.
 * ----------------------------------------------------------------------- */
union kbase_ioctl_get_cpu_gpu_timeinfo {
   struct {
      __u32 request_flags;
      __u32 paddings[7];
   } in;
   struct {
      __u64 sec;
      __u32 nsec;
      __u32 padding;
      __u64 timestamp;
      __u64 cycle_counter;
   } out;
};
#define KBASE_IOCTL_GET_CPU_GPU_TIMEINFO \
   _IOWR(KBASE_IOCTL_TYPE, 50, union kbase_ioctl_get_cpu_gpu_timeinfo)

#define BASE_TIMEINFO_MONOTONIC_FLAG     (1u << 0)
#define BASE_TIMEINFO_TIMESTAMP_FLAG     (1u << 1)
#define BASE_TIMEINFO_CYCLE_COUNTER_FLAG (1u << 2)
