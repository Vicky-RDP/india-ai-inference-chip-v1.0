# IAIC v1.0 firmware spike

`iaic_v1.h` and `iaic_v1.c` provide the first host-side integration contract
for the 32-bit MMIO adapter. The driver stages up to 16 signed INT8 lanes,
submits one command, polls `STATUS.result_valid`, and reads `RESULT`.

The exported packing helper and `iaic_linear_dma_descriptor_t` are an
experimental bridge toward the DMA workstream. They validate the word-oriented
address/length convention but do not access hardware; the DMA register map is
not frozen yet.

This is a portable C reference driver, not a board support package. A RISC-V
firmware or RTOS port can replace the raw `volatile uint32_t *` base with its
platform's device mapping and add interrupt-driven completion later.

Compile the driver-only check with:

```bash
make firmware-test
```
