# India Inference Chip — project blueprint

Status: active bring-up

This blueprint is the shared map for the project. It defines the first silicon
target, the interfaces that must become stable, the public artifacts required
at each gate, and the rules that let contributors work independently without
creating an integration maze.

## 1. Product thesis

India Inference Chip (IIC) is an open hardware and software stack for efficient
edge inference. The first chip is a learning vehicle and a trustworthy public
reference design, not a claim that a small first tapeout will beat commercial
accelerators on every workload.

The project optimizes for:

- bit-accurate and reproducible behavior;
- a portable, vendor-neutral RTL core;
- an FPGA prototype before ASIC submission;
- a simple software-visible contract;
- public evidence for area, timing, throughput, power, and limitations; and
- a welcoming path for contributors who are new to chip design.

## 2. First tapeout definition of done

The first tapeout is a small, testable inference subsystem with a RISC-V
control path and an INT8 compute path. The exact process, shuttle, package, and
board are release-blocking decisions recorded in docs/decisions/.

The minimum tapeout candidate contains:

1. a parameterized signed INT8 dot-product / matrix tile;
2. a documented ready/valid streaming interface;
3. a scratchpad or tightly scoped memory interface;
4. a register map and software ABI;
5. reset, clock, interrupt, and error behavior;
6. self-checking simulation, lint, assertions, and formal properties where
   tools permit;
7. synthesis, timing, utilization, and power estimates with tool versions;
8. a reproducible physical-design flow and signoff checklist; and
9. a bring-up plan with observable test points and fallback firmware.

If a feature is not necessary to prove this loop, it belongs after the first
tapeout. Keeping the first target narrow is a safety and schedule decision.

## 3. Layered architecture

Applications and model examples
          |
Quantization + compiler lowering + runtime API
          |
RISC-V host / command queue / interrupt and status registers
          |
DMA + scratchpad + tiled INT8 compute engine
          |
Portable SystemVerilog -> FPGA prototype -> ASIC implementation

### Stable boundaries

| Boundary | First public contract | Owner |
| --- | --- | --- |
| Numeric | Signed INT8 × INT8, signed 32-bit accumulation, explicit overflow policy | Architecture + RTL |
| Streaming | valid/ready, one result per accepted request, no data change while stalled | RTL + verification |
| Control | Register map, command lifecycle, status and error codes | Firmware + architecture |
| Memory | Tensor layout, alignment, burst limits, scratchpad ownership | Architecture + compiler |
| Software | Reference operator, runtime example, versioned ABI | Compiler + runtime |
| Evidence | Re-run commands, tool versions, raw reports, limitations | All workstreams |

## 4. Repository contract

- rtl/ contains synthesizable SystemVerilog only.
- tb/ contains simulation-only tests and directed/randomized stimuli.
- tools/ contains reference models, generators, and report utilities.
- docs/ contains architecture, decisions, schedules, and contributor guides.
- .github/ contains policy-as-code: CI, ownership, templates, and moderation.
- website/ is the public project front door and links back to the source of
  truth in GitHub.

Every new hardware block must ship with its numeric contract, interface timing,
reset semantics, a self-checking test, and a reproducible command. Every
architectural change gets a short decision record before merge.

## 5. Engineering gates

No gate is complete because code exists. It is complete when the evidence is
public and another contributor can reproduce it from a clean checkout.

| Gate | Exit evidence |
| --- | --- |
| G0 — arithmetic | Reference model and RTL agree on nominal, signed, zero, max, min, and reset cases |
| G1 — stream | Backpressure, bubbles, throughput, and ordering are verified |
| G2 — tile | Matrix tile matches a golden model and has a documented memory layout |
| G3 — FPGA | Bitstream, board setup, utilization, timing, and measured benchmark are published |
| G4 — ASIC-ready | Lint, CDC, assertions/formal, synthesis, STA, DRC/LVS strategy, and waiver log are reviewed |
| G5 — tapeout | Frozen source, signed-off reports, release tag, bring-up firmware, and contingency plan are archived |

## 6. How the world contributes

The default unit of work is a small issue-linked pull request. Contributors can
start with documentation, test vectors, waveform review, Python models,
benchmark harnesses, compiler experiments, FPGA support, or RTL. A maintainer
should be able to answer three questions from every PR:

1. What contract changed?
2. What evidence proves it?
3. What should the next contributor do?

Use the Getting Started guide at ../GETTING_STARTED.md, select a workstream,
and open a public design discussion before changing a shared interface.

## 7. Non-goals for v1

The first release does not promise a general-purpose NPU, a production compiler,
security certification, or commercial performance parity. Those are possible
future directions, but they are not allowed to silently expand the tapeout
critical path.

