# IAIC v1.0 processor interface

This document defines the first stable interface between a host and the
`ii_inference_processor` RTL block. It is intentionally small enough for an
FPGA shell today and clear enough to map onto a future RISC-V bus, DMA engine,
or memory-mapped device.

## Command stream

A command is accepted on a rising clock edge when both `cmd_valid` and
`cmd_ready` are high. The command contains two packed vectors:

```text
cmd_activations[8*i +: 8] = signed activation for lane i
cmd_weights[8*i +: 8]     = signed weight for lane i
```

Lane 0 is therefore in the least-significant byte. Each lane performs signed
INT8 multiplication, and all products are accumulated into the signed
`ACC_WIDTH` result. The default configuration is 16 lanes and a 32-bit
accumulator.

The processor contains a four-entry command queue by default. The queue depth
is configurable with `CMD_QUEUE_DEPTH`. `cmd_ready` deasserts when the queue is
full or when `CONTROL.enable` is clear.

## Result stream

The result is transferred on a rising edge when `result_valid` and
`result_ready` are both high. While `result_valid` is high and `result_ready`
is low, `result` must remain unchanged. The result stream may be consumed at
one result per clock once the pipeline is full.

## CSR request/response

CSR requests are accepted whenever `csr_ready` is high. The current block ties
`csr_ready` high and returns a registered response one cycle after
`csr_valid`. Writes return a response with `csr_rdata = 0`.

| Address | Register | Read behavior | Write behavior |
| --- | --- | --- | --- |
| `0x0` | `CONTROL` | bit 0 `enable`; bit 1 `irq_enable` | bit 0 enables new commands; bit 1 enables interrupt; bit 2 clears sticky `done` |
| `0x4` | `STATUS` | bit 0 `busy`; bit 1 `done`; bit 2 `cmd_ready`; bit 3 `result_valid` | ignored |
| `0x8` | `RESULT` | signed accumulator result as a 32-bit word | ignored |
| `0xc` | `VERSION` | `0x0001_0000` | ignored |

`done` is set when a result is consumed and remains set until `CONTROL.bit2`
is written as one or reset. `irq` is asserted while both `done` and
`irq_enable` are set.

## 32-bit MMIO adapter

`rtl/ii_inference_processor_mmio.sv` exposes the same CSR registers plus
vector staging registers for a simple FPGA or RISC-V memory-mapped shell:

| Address range | Purpose |
| --- | --- |
| `0x00`–`0x0c` | `CONTROL`, `STATUS`, `RESULT`, and `VERSION` CSRs |
| `0x10`–`0x1c` | Activation vector, four bytes per word |
| `0x20`–`0x2c` | Weight vector, four bytes per word |
| `0x30` | Write to submit the staged vector pair |

The vector ranges contain `ceil(LANES / 4)` words each. A command write waits
with `bus_ready` low while the processor command queue is full. Reading
`RESULT` consumes the current result and sets sticky completion.

## Reset

`rst_n` is an asynchronous active-low reset. Reset clears the command queue,
pending result, control enables, CSR response, and sticky completion state.

## Example transaction

For four lanes, the values below encode `[1, -2, 3, -4]` and `[2, 3, -4, -5]`:

```text
cmd_activations = 32'hfc03fe01
cmd_weights     = 32'hfbfc0302
result          = 32'd4
```

The vectors are intentionally shown in hexadecimal so the byte ordering is
unambiguous for software and test generators.

The portable C reference driver in [firmware/iaic_v1.c](../firmware/iaic_v1.c)
uses this exact sequence: enable and clear completion, write four activation
words and four weight words, write `COMMAND`, poll `STATUS.result_valid`, and
read `RESULT`.
