# India Inference Chip

An open-source hardware and software project for efficient AI inference, designed and developed in India.

## Project goal

India Inference Chip (IIC) aims to make practical AI inference hardware accessible to students, researchers, startups, and embedded-systems builders. The project will develop a reproducible path from open RTL and software to an FPGA prototype and, eventually, an open ASIC implementation.

The first milestone is intentionally narrow: a verified signed INT8 dot-product engine that can become the compute primitive for convolution and transformer workloads.

## v0 architecture

```text
                 +----------------------+
                 | RISC-V host / driver |
                 +----------+-----------+
                            |
                       control + DMA
                            |
                 +----------v-----------+
                 | INT8 inference core |
                 | 16-lane dot product  |
                 +----------+-----------+
                            |
                       scratchpad SRAM
```

The v0 design targets:

- Signed INT8 activations and weights
- 32-bit accumulation
- Parameterized lane count, defaulting to 16
- One-cycle result latency after accepting an input vector
- FPGA-friendly synchronous RTL
- A software reference model for bit-accurate testing

## Repository layout

```text
rtl/                    Synthesizable SystemVerilog
tb/                     RTL testbenches
tools/                  Reference models and developer utilities
docs/                   Architecture and project documentation
.github/workflows/      Continuous integration
```

## Quick start

Install a SystemVerilog simulator such as Icarus Verilog or Verilator, then run:

```bash
make test
python3 tools/reference_model.py
```

The RTL testbench is intentionally self-contained and does not require a proprietary EDA tool.

## Current status

This repository is at the bring-up stage. The first useful contributions are RTL tests, synthesis reports, FPGA targets, and a clear software interface. See [docs/roadmap.md](docs/roadmap.md) for the planned milestones.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening an issue or pull request. Design discussions should include measurable targets and reproducible test cases.

## License

The initial repository is released under Apache License 2.0. Before an ASIC tape-out, the hardware licensing model will be reviewed with contributors; CERN-OHL-S-2.0 is a candidate for a future hardware-specific licence. See [LICENSE](LICENSE).
