# Architecture v0 / IAIC v1.0 processor slice

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

`rtl/ii_inference_processor.sv` is the first control-and-compute processor
slice. It combines the stream wrapper with a small CSR interface that a future
RISC-V host, DMA engine, or FPGA shell can drive. It is intentionally not a
general-purpose CPU or a complete NPU yet; it establishes the first stable
software-visible execution contract.

## Processor slice contract

The command interface accepts one packed activation vector and one packed
weight vector when `cmd_valid && cmd_ready` is true. The result is presented
through `result_valid`, `result_ready`, and `result`; it remains stable while
the consumer applies backpressure. Only one result can be in flight in this
first implementation.

CSR requests are single-cycle and always accepted (`csr_ready` is high). A
response is registered and returned on the following rising edge through
`csr_rsp_valid` and `csr_rdata`.

| Address | Name | Read | Write |
| --- | --- | --- | --- |
| `0x0` | `CONTROL` | bit 0 `enable`, bit 1 `irq_enable` | bit 0 enables new commands; bit 1 enables `irq`; bit 2 clears sticky `done` |
| `0x4` | `STATUS` | bit 0 `busy`, bit 1 `done`, bit 2 `cmd_ready`, bit 3 `result_valid` | ignored |
| `0x8` | `RESULT` | most recent signed accumulator result | ignored |
| `0xc` | `VERSION` | `0x0001_0000` for IAIC v1.0 | ignored |

`done` becomes sticky when a result is consumed (`result_valid &&
result_ready`). `irq` is `done && irq_enable`. A completion in the same cycle
as a clear wins, so an event cannot be lost.

The complete host-facing contract, including lane packing and an example
transaction, is in [processor-interface.md](processor-interface.md).

## Next architectural steps

1. Expand the processor slice into a command queue and software ABI.
2. Tile dot products into a matrix-multiply engine.
3. Add a scratchpad and DMA path.
4. Connect a RISC-V host core and benchmark quantized models.
5. Add compiler lowering, runtime APIs, and FPGA board support.

## Success metrics

Every milestone should report:

- Correctness against the Python reference model
- Maximum clock frequency after synthesis
- LUTs, flip-flops, DSP blocks, and SRAM usage on the target FPGA
- Throughput, latency, and energy per inference when a board measurement is available
