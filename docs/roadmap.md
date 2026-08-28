# Roadmap

The roadmap is intentionally public and adjustable. Issues and design discussions are the source of truth for detailed work.

## Starting today

- Invite contributors worldwide through GitHub Issues and Discussions.
- Make the first RTL, testbench, and reference model easy to run.
- Turn the dot-product primitive into a documented streaming block.
- Establish reproducible measurements before making performance claims.

## Milestone 0 — repository bring-up

- [x] Establish open-source repository structure
- [x] Define INT8 dot-product numeric contract
- [x] Add portable RTL and self-checking testbench
- [x] Add Python reference model
- [x] Add continuous integration with an RTL simulator

## Milestone 1 — FPGA proof of concept

- [x] Add a streaming wrapper
- [ ] Add a LiteX integration target
- [ ] Run on one low-cost FPGA development board
- [ ] Publish synthesis and benchmark results

## Milestone 2 — matrix engine

- [x] Add configurable matrix-multiply tiling
- [x] Add scratchpad SRAM primitive
- [ ] Add scratchpad DMA
- [x] Define a stable command interface
- [ ] Run a small ONNX model end to end

## Milestone 3 — open ASIC preparation

- [ ] Select an open PDK and shuttle-compatible design target
- [ ] Complete lint, CDC, formal, and synthesis checks
- [ ] Add physical-design scripts and reproducible reports
- [ ] Freeze a small test chip and submit for fabrication

## Milestone 4 — developer ecosystem

- [ ] Publish a board support package
- [ ] Publish compiler/runtime documentation
- [ ] Create example applications for vision, audio, and robotics
- [ ] Build a contributor and university onboarding guide
