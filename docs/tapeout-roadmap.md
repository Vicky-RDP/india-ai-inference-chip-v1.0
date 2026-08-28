# Tapeout roadmap: 2026-08-26 → 2027-07-23

Target: submit the first small IIC test chip in **under 11 months** from the
current bring-up date. This is an execution target, not a guarantee. It assumes
a committed core team, fast access to an appropriate open or partner PDK, a
shuttle slot, and disciplined scope control. If a dependency slips, the
maintainers must publish the impact rather than hide schedule risk.

## Operating cadence

- Weekly: workstream stand-up in GitHub Discussions; blockers are converted to
  issues with an owner and due date.
- Every two weeks: integration branch cut, CI review, and roadmap update.
- Monthly: public engineering report with correctness, area, timing, power, and
  contributor metrics.
- At each gate: one design review, one verification review, and one independent
  signoff from outside the implementing workstream.

## Critical path

| Window | Gate and outcome | Required public artifacts |
| --- | --- | --- |
| Aug 26–Sep 20, 2026 | G0: freeze v0 arithmetic and contribution contracts | Blueprint, issue backlog, CI, signed INT8 spec, reference vectors |
| Sep 21–Oct 25 | G1: streaming compute block | Ready/valid RTL, randomized tests, assertions, latency/throughput note |
| Oct 26–Nov 29 | G2: tiled compute and memory plan | Tile spec, tensor layout, scratchpad proposal, golden matrix tests |
| Nov 30–Jan 10, 2027 | G2.5: software-visible prototype | Register map, command format, Python/C reference driver, FPGA candidate |
| Jan 11–Feb 21 | G3: FPGA proof | Board target, bitstream recipe, utilization/timing report, benchmark harness |
| Feb 22–Mar 28 | G3 exit and ASIC target selection | PDK/shuttle decision record, scope freeze, risk register, test strategy |
| Mar 29–May 2 | G4: ASIC RTL hardening | Lint, CDC, assertions/formal, synthesis, timing constraints, waivers |
| May 3–Jun 6 | G4: physical implementation | Floorplan, power grid, clocks, DRC/LVS flow, area/timing/power reports |
| Jun 7–Jun 27 | G4.5: full-chip verification | Regression, firmware smoke test, signoff checklist, independent review |
| Jun 28–Jul 11 | G5: release candidate | Frozen tag candidate, reproducible archive, release notes, bring-up plan |
| Jul 12–Jul 23 | Tapeout window | Final signoff, submission package, public tapeout announcement |

## Workstream ownership

| Workstream | Accountable deliverable | Minimum staffing target |
| --- | --- | ---: |
| Architecture | Contracts, decisions, integration plan | 2 |
| RTL + verification | Core, wrappers, regressions, assertions | 3 |
| FPGA + ASIC | Board flow, synthesis, physical design, signoff | 3 |
| Firmware + RISC-V | Register map, boot, driver, diagnostics | 2 |
| Compiler + runtime | Quantization, operator lowering, examples | 2 |
| Benchmarks | Workloads, methodology, power/latency evidence | 2 |
| Community + release | Docs, triage, onboarding, release hygiene | 2 |

These are targets for parallel ownership, not a barrier to contribution. One
person may cover multiple roles early; no critical gate should depend on one
person's unreviewed work.

## Schedule controls

1. The tapeout branch accepts only issue-linked changes with green CI.
2. Interface changes require an ADR and a migration note.
3. Every critical-path issue has a named owner, a reviewer, and a fallback.
4. Any two-week slip triggers a scope review; it does not trigger silent
   overtime or unreviewed feature cuts.
5. The first shuttle target remains deliberately small. Larger models, custom
   compression, and aggressive physical optimization are post-tapeout work.

## First 10 issues to open

1. [x] Add randomized streaming regression and seed capture.
2. [x] Add a ready/valid dot-product wrapper.
3. [x] Draft the tensor packing contract and host-facing staging interface.
4. [x] Define the v0 register map.
5. [x] Add optional Verilator lint and warning policy.
6. Select two FPGA evaluation boards with cost and availability evidence.
7. [x] Build a reproducible Yosys synthesis-report workflow.
8. [x] Prototype an INT8 Python operator API.
9. [x] Create the first RISC-V-oriented host integration spike.
10. Compare candidate open PDK/shuttle paths and record assumptions.
