/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright 2026 India AI Inference Chip v1.0 contributors */

#include "iaic_v1.h"

static uint32_t mmio_read(volatile uint32_t *base, uint32_t offset)
{
    return base[offset / sizeof(uint32_t)];
}

static void mmio_write(volatile uint32_t *base, uint32_t offset, uint32_t value)
{
    base[offset / sizeof(uint32_t)] = value;
}

uint32_t iaic_pack_int8_word(const int8_t *values, size_t lanes, size_t first_lane)
{
    uint32_t word = 0u;
    size_t byte;

    for (byte = 0; byte < 4u; ++byte) {
        size_t lane = first_lane + byte;
        if (lane < lanes) {
            word |= (uint32_t)(uint8_t)values[lane] << (byte * 8u);
        }
    }
    return word;
}

int iaic_validate_linear_dma(const iaic_linear_dma_descriptor_t *descriptor)
{
    if (descriptor == NULL || descriptor->length_words == 0u) {
        return IAIC_ERR_ARGUMENT;
    }
    if (descriptor->base_word_addr > UINT32_MAX - (descriptor->length_words - 1u)) {
        return IAIC_ERR_ARGUMENT;
    }
    return IAIC_OK;
}

int iaic_run_dot_product(volatile uint32_t *base,
                         const int8_t *activations,
                         const int8_t *weights,
                         size_t lanes,
                         uint32_t timeout_cycles,
                         int32_t *result)
{
    size_t word;

    if (base == NULL || activations == NULL || weights == NULL || result == NULL ||
        lanes == 0u || lanes > IAIC_MAX_LANES) {
        return IAIC_ERR_ARGUMENT;
    }

    /* Enable execution and clear completion from any previous command. */
    mmio_write(base, IAIC_CONTROL_OFFSET, IAIC_CONTROL_ENABLE | IAIC_CONTROL_CLEAR_DONE);
    for (word = 0; word < (IAIC_MAX_LANES / 4u); ++word) {
        mmio_write(base, IAIC_ACTIVATION_BASE + (uint32_t)(word * 4u),
                   iaic_pack_int8_word(activations, lanes, word * 4u));
        mmio_write(base, IAIC_WEIGHT_BASE + (uint32_t)(word * 4u),
                   iaic_pack_int8_word(weights, lanes, word * 4u));
    }

    mmio_write(base, IAIC_COMMAND_OFFSET, 1u);
    while (timeout_cycles-- > 0u) {
        if ((mmio_read(base, IAIC_STATUS_OFFSET) & IAIC_STATUS_RESULT_VALID) != 0u) {
            *result = (int32_t)mmio_read(base, IAIC_RESULT_OFFSET);
            return IAIC_OK;
        }
    }

    return IAIC_ERR_TIMEOUT;
}
