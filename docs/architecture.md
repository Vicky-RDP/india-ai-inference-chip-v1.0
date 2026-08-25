# Architecture v0

## Scope

The first hardware milestone is a portable INT8 dot-product primitive. It is not yet a complete neural-network accelerator. Keeping the first block small lets us establish bit-accurate behavior, verification, synthesis, and FPGA integration before adding architectural complexity.

## Numeric contract

- Inputs are signed two's-complement 8-bit integers.
- Each lane computes `activation[i] * weight[i]` as a signed 16-bit product.
- Products are accumulated into a signed 32-bit register.
- The v0 block does not saturate; software and later higher-level blocks must define quantization and saturation policy.
- The result is registered and marked valid for one cycle.

## Interface contract

`ii_dot_product` accepts one packed activation vector and one packed weight vector when `valid_in` is high. `valid_out` is asserted on the following rising edge and `result` contains the signed 32-bit sum.

The lane count is a parameter so the same RTL can be used for a small educational FPGA target or a larger accelerator tile.

rtl/ii_dot_product_stream.sv adds the first software- and system-facing
ready/valid wrapper. It has one output entry, accepts a new request whenever
the output is empty or consumed, and holds result stable while downstream
backpressure is asserted. The corresponding testbench covers reset, signed edge
values, acceptance, and a stalled consumer.

## Next architectural steps

1. Add a streaming input interface and backpressure.
2. Tile dot products into a matrix-multiply engine.
3. Add a scratchpad and DMA path.
4. Define a minimal command queue and software ABI.
5. Connect a RISC-V host core and benchmark quantized models.

## Success metrics

Every milestone should report:

- Correctness against the Python reference model
- Maximum clock frequency after synthesis
- LUTs, flip-flops, DSP blocks, and SRAM usage on the target FPGA
- Throughput, latency, and energy per inference when a board measurement is available
