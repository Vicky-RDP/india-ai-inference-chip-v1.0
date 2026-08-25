# India AI Inference Chip v1.0

## India needs its own AI inference chip. Let’s build it in the open.

India AI Inference Chip v1.0 (IAIC v1.0) is a global open-source hardware and software project to develop efficient AI inference silicon originating from India.

We believe the fastest path is collaboration: publish the architecture, RTL, verification, compiler, firmware, benchmarks, and design decisions so developers everywhere can study them, improve them, and build on them.

Indian developers, researchers, students, startups, universities, hardware engineers, software engineers, and contributors from every country are invited to participate from today.

## What we are building

The project will progress from a small, verifiable accelerator to a complete inference platform:

```text
models and applications
          |
compiler + runtime + drivers
          |
RISC-V host + inference accelerator
          |
FPGA prototype -> open ASIC implementation -> developer hardware
```

The first milestone is a portable signed INT8 dot-product engine. It is deliberately small so that contributors can get started immediately while we build toward tiled matrix multiplication, memory systems, model tooling, and eventually a fabricated chip.

## Why open source?

- More people can review correctness, security, and performance.
- Universities and startups can learn from and extend the design.
- Hardware, software, compiler, and applications can evolve together.
- Contributors can work from India or anywhere else in the world.
- Every important result should be reproducible from public source.

## Current v0 target

- Signed INT8 activations and weights
- 32-bit accumulation
- Parameterized 16-lane dot-product core
- Portable SystemVerilog RTL
- Self-checking RTL testbench
- Python bit-accurate reference model
- FPGA-first development, followed by an open ASIC path

This is an early project. It is not yet production silicon, a commercial product, or a claim of competitive performance. We will earn those claims through open benchmarks and reproducible evidence.

## Start contributing today

1. Read [GETTING_STARTED.md](GETTING_STARTED.md).
2. Run the reference model and RTL testbench:

   ```bash
   make reference
   make test
   ```

3. Choose a workstream in [docs/workstreams.md](docs/workstreams.md).
4. Look for issues labelled `good first issue`, `help wanted`, or `design discussion`.
5. Open an issue before a substantial change so the community can align early.

You do not need to be an expert in chip design to help. Documentation, verification, Python tooling, compiler work, benchmarks, FPGA integration, and thoughtful review are all first-class contributions.

## Repository map

```text
rtl/                    Synthesizable SystemVerilog
tb/                     RTL testbenches
tools/                  Reference models and developer utilities
docs/                   Architecture, roadmap, workstreams, and decisions
.github/                CI, issue forms, pull request guidance, and ownership
```

## Project principles

1. Open by default: designs, interfaces, measurements, and decisions belong in public artifacts.
2. Reproducible by default: include test vectors, scripts, tool versions, and measurement context.
3. Portable by default: keep the core usable across open tools and FPGA targets.
4. Evidence over hype: publish limitations as clearly as successes.
5. Welcoming by default: global contributors should be able to participate without insider context.
6. Safety matters: do not publish secrets, private data, or instructions that create avoidable harm.

## License

The initial project is released under the permissive [Apache License 2.0](LICENSE), including hardware source, software, documentation, and test material unless a file states otherwise. Apache-2.0 is intentional: contributors and downstream users should be able to study, modify, manufacture, integrate, and commercialize the work while preserving attribution and patent protections.

Before an ASIC tape-out, the community will review whether a dual-license or hardware-specific licence improves protection for contributors without reducing adoption. No change will be made without a public decision and migration plan.

## Community

- Questions and design discussions: GitHub Issues and Discussions
- Proposed changes: Pull Requests
- Security reports: [SECURITY.md](SECURITY.md)
- Governance: [GOVERNANCE.md](GOVERNANCE.md)
- Contributor expectations: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

## Invitation

If you care about open hardware, AI, RISC-V, semiconductors, education, or India’s technology independence, join us. Star the repository, introduce yourself in a discussion, pick an issue, or open a proposal. The project starts with a small core, but its success depends on a worldwide community building the full stack together.
