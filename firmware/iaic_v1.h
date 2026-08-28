/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright 2026 India AI Inference Chip v1.0 contributors */

#ifndef IAIC_V1_H
#define IAIC_V1_H

#include <stddef.h>
#include <stdint.h>

#define IAIC_CONTROL_OFFSET 0x00u
#define IAIC_STATUS_OFFSET 0x04u
#define IAIC_RESULT_OFFSET 0x08u
#define IAIC_VERSION_OFFSET 0x0cu
#define IAIC_ACTIVATION_BASE 0x10u
#define IAIC_WEIGHT_BASE 0x20u
#define IAIC_COMMAND_OFFSET 0x30u

#define IAIC_CONTROL_ENABLE (1u << 0)
#define IAIC_CONTROL_IRQ_ENABLE (1u << 1)
#define IAIC_CONTROL_CLEAR_DONE (1u << 2)
#define IAIC_STATUS_BUSY (1u << 0)
#define IAIC_STATUS_DONE (1u << 1)
#define IAIC_STATUS_CMD_READY (1u << 2)
#define IAIC_STATUS_RESULT_VALID (1u << 3)

#define IAIC_MAX_LANES 16u
#define IAIC_OK 0
#define IAIC_ERR_ARGUMENT -1
#define IAIC_ERR_TIMEOUT -2

/* The pointer must refer to the base of ii_inference_processor_mmio. */
int iaic_run_dot_product(volatile uint32_t *base,
                         const int8_t *activations,
                         const int8_t *weights,
                         size_t lanes,
                         uint32_t timeout_cycles,
                         int32_t *result);

#endif
