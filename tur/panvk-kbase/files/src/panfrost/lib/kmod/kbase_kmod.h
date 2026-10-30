/*
 * Copyright © 2026 Collabora, Ltd.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <stdint.h>

#if defined(__cplusplus)
extern "C" {
#endif

struct drm_panthor_csif_info;

struct pan_kmod_dev;

/* CSF interface information for a kbase CSF device, presented in the
 * panthor uAPI layout so CSF-generic code can consume either backend.
 * Filled from KBASE_IOCTL_CS_GET_GLB_IFACE at device-create time.
 * Only valid for CSF (arch >= 10) kbase devices.
 */
const struct drm_panthor_csif_info *
kbase_kmod_get_csif_props(const struct pan_kmod_dev *dev);

/* Current LATEST_FLUSH value from the CSF USER register page (the kbase
 * equivalent of panthor_kmod_get_flush_id()). */
uint32_t kbase_kmod_get_flush_id(const struct pan_kmod_dev *dev);

/* True when this kbase context can allocate dma-bufs for sharing with WSI. */
bool kbase_kmod_supports_dmabuf(const struct pan_kmod_dev *dev);

/* CSF queue group / queue / tiler heap primitives (CSF only).
 *
 * A queue is a ring buffer in a GPU BO: bind it to a group at a CS index,
 * mmap the returned USER_IO pages (doorbell / input / output), write CS
 * instructions into the ring, publish the new insert offset in the input
 * page and kick.  Progress is visible through CS_EXTRACT / CS_ACTIVE in
 * the output page.
 */
int kbase_kmod_csf_group_create(struct pan_kmod_dev *dev,
                                uint32_t cs_queue_count,
                                uint32_t *group_handle);
void kbase_kmod_csf_group_destroy(struct pan_kmod_dev *dev,
                                  uint32_t group_handle);

/* Registers and binds the ring buffer at ringbuf_va; returns the mmap()ed
 * USER_IO pages (BASEP_QUEUE_NR_MMAP_USER_PAGES) or NULL on failure. */
void *kbase_kmod_csf_queue_bind(struct pan_kmod_dev *dev,
                                uint32_t group_handle, uint32_t csi_index,
                                uint64_t ringbuf_va, uint32_t ringbuf_size);
void kbase_kmod_csf_queue_term(struct pan_kmod_dev *dev, uint64_t ringbuf_va,
                               void *user_io);
int kbase_kmod_csf_queue_kick(struct pan_kmod_dev *dev, uint64_t ringbuf_va);

/* Block (up to timeout_ns) until the kernel has a CSF notification, then
 * consume one notification with read().  Lets the kernel event/OOM/
 * scheduler path make progress while userspace waits for completion.
 * Returns 0 on success (event consumed or timeout), -1 on error. */
int kbase_kmod_csf_wait_event(struct pan_kmod_dev *dev, int64_t timeout_ns);

/* Wait for a 64-bit CSF event object to become greater than target_minus_one
 * using a kernel CPU queue and a sync_file fence.  The event address must
 * refer to a 16-byte-aligned BASE_MEM_CSF_EVENT allocation.  Returns 1 when
 * satisfied, 0 on timeout, and -1 when the path is unavailable so callers can
 * retain their notification/read fallback. */
int kbase_kmod_csf_wait_cqs64(struct pan_kmod_dev *dev, uint64_t addr,
                              uint64_t target_minus_one,
                              int64_t timeout_ns);

/* Report whether this kbase context has seen a queue-group error.  The error
 * state is latched while completion waits consume the notification stream. */
bool kbase_kmod_csf_has_error(const struct pan_kmod_dev *dev);

int kbase_kmod_csf_tiler_heap_create(struct pan_kmod_dev *dev,
                                     uint32_t chunk_size,
                                     uint32_t initial_chunks,
                                     uint32_t max_chunks,
                                     uint32_t target_in_flight,
                                     uint32_t mem_group_id,
                                     uint64_t *heap_ctx_va,
                                     uint64_t *first_chunk_va);
void kbase_kmod_csf_tiler_heap_destroy(struct pan_kmod_dev *dev,
                                       uint64_t heap_ctx_va);

/* Map a (GPU-cached, SAME_VA) BO `nents` times back-to-back at a single
 * VA using KBASE_IOCTL_MEM_ALIAS — the kbase substitute for mapping one
 * BO at several chosen addresses (used for wraparound ring buffers).
 * The kernel picks the address (kbase rejects address hints); the
 * mapping is guaranteed not to cross a 4G boundary.  Returns the base VA
 * of the repeated mapping (CPU == GPU), or 0 on failure.  Release with
 * kbase_kmod_alias_destroy(). */
uint64_t kbase_kmod_alias_create(struct pan_kmod_dev *dev, uint64_t bo_va,
                                 uint64_t size, uint32_t nents);
void kbase_kmod_alias_destroy(struct pan_kmod_dev *dev, uint64_t va,
                              uint64_t size, uint32_t nents);

#if defined(__cplusplus)
} // extern "C"
#endif
