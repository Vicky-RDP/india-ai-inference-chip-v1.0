# FPGA integration scaffold

The FPGA workstream starts with the board-neutral
`rtl/ii_inference_processor_mmio.sv` adapter. It provides a small 32-bit
request/response port, activation and weight staging registers, a command
submit register, and an interrupt output. A board target only needs to supply
clock/reset, connect a host-facing bus, and add pin constraints.

## Bring-up sequence

1. Run `make ci` for simulator and lint coverage.
2. Run `make synth-report` after installing Yosys and archive the report.
3. Instantiate `ii_inference_processor_mmio` in a board top-level.
4. Connect the board clock and hold `rst_n` low through clock stabilization.
5. Use the MMIO map in [the processor interface](../docs/processor-interface.md)
   to enable, stage, submit, and read one signed INT8 dot product.
6. Record the board, tool versions, clock constraints, utilization, timing,
   and measured latency in a dated report before making performance claims.

The board-neutral preflight is available as `make fpga-smoke`; it exercises the
MMIO, matrix, scratchpad, and DMA paths before hardware-specific work begins.

## Board target acceptance criteria

Each target should document these facts before being considered supported:

- exact board and FPGA part number;
- open-source tool versions and installation command;
- clock frequency and reset behavior;
- bitstream build command;
- LUT/FF/DSP/BRAM utilization and timing slack;
- host-to-processor transport and a smoke-test transcript; and
- known limitations, especially whether the board exposes power telemetry.

No board is selected by this scaffold. The project will record the decision and
evidence in a future board-specific target directory once a contributor has
validated a complete build.
