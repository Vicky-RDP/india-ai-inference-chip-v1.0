# Contributing to India Inference Chip

Thank you for helping build open AI hardware from India for the world. Contributors from every country and experience level are welcome.

## Before opening a pull request

1. Explain the problem and the measurable effect of the proposed change.
2. Add or update tests for RTL behavior.
3. Run `make test` locally when a simulator is available.
4. Keep synthesizable RTL separate from testbench-only code.
5. Document interface, numeric-width, and latency changes.

You do not need permission to start improving documentation, tests, tooling, benchmarks, or a proposed design. For substantial architectural work, open an issue or discussion first so others can join the design conversation.

There is no contributor nationality, employer, or membership requirement. Contributions are made under the repository licence; a separate CLA is not required at this stage.

## Design principles

- Prefer simple, inspectable hardware over opaque optimization.
- Make numeric behavior explicit: signedness, rounding, saturation, and overflow must be documented.
- Keep the default configuration useful on low-cost FPGA boards.
- Avoid vendor-specific primitives in the portable core.
- Treat reproducibility as a feature: scripts and test vectors belong in the repository.

## Commit messages

Use short imperative subjects, for example:

```text
Add signed INT8 dot-product core
Document accumulator overflow behavior
```

## Code of conduct

Be respectful, technically rigorous, and welcoming. Harassment or discrimination is not acceptable in project spaces.
