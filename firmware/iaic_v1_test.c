/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright 2026 India AI Inference Chip v1.0 contributors */

#include <assert.h>

#include "iaic_v1.h"

int main(void)
{
    const int8_t values[4] = {1, -2, 3, -4};
    iaic_linear_dma_descriptor_t descriptor = {10u, 4u};
    iaic_linear_dma_descriptor_t invalid = {UINT32_MAX, 2u};

    assert(iaic_pack_int8_word(values, 4u, 0u) == 0xfc03fe01u);
    assert(iaic_pack_int8_word(values, 4u, 2u) == 0x0000fc03u);
    assert(iaic_validate_linear_dma(&descriptor) == IAIC_OK);
    assert(iaic_validate_linear_dma(NULL) == IAIC_ERR_ARGUMENT);
    assert(iaic_validate_linear_dma(&invalid) == IAIC_ERR_ARGUMENT);
    return 0;
}
