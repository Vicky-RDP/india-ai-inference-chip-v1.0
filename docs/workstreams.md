# Workstreams

Contributors can work independently in these areas. If you are unsure where an idea fits, open a Discussion.

## Hardware architecture

Define the accelerator programming model, tensor layouts, quantization behavior, memory hierarchy, interfaces, and performance targets.

Starter tasks: streaming valid/ready interface, matrix tile design, scratchpad specification, command format.

## RTL and verification

Build portable, synthesizable SystemVerilog and prove that it matches the numerical contract.

Starter tasks: randomized dot-product tests, reset/handshake tests, assertions, Verilator linting, formal properties, synthesis reports.

## FPGA and ASIC flow

Make the design run on accessible hardware and keep the eventual ASIC path reproducible.

Starter tasks: LiteX integration, board target, clock/reset strategy, open-PDK experiments, reproducible utilization reports.

## Compiler and runtime

Turn real models into commands and buffers understood by the accelerator.

Starter tasks: model operator inventory, quantization reference, ONNX import experiment, host API, runtime examples.

## Firmware and RISC-V integration

Connect a host processor, registers, DMA, interrupts, boot flow, and device drivers.

Starter tasks: register map, bare-metal example, RISC-V soft-core evaluation, Linux or Zephyr driver investigation.

## Benchmarks and applications

Measure end-to-end value on workloads that matter for edge inference.

Starter tasks: benchmark harness, reproducible model set, latency/throughput/power methodology, vision and audio examples.

## Documentation and community

Make the project understandable and welcoming to people entering from different backgrounds.

Starter tasks: diagrams, tutorials, glossary, translated onboarding material, contributor interviews, issue triage.
