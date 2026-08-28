# Reproducible synthesis reports

The first synthesis entry point targets Yosys and the portable IAIC v1.0
processor slice. It reports the elaborated design statistics and emits a JSON
netlist for later FPGA/ASIC flow experiments.

Run it with:

```bash
make synth-report
```

The report and netlist are written under `build/synthesis/`. If Yosys is not
installed, the command prints a clear skip message and leaves the source tree
unchanged. The report is only a baseline: clock frequency, placement, routing,
power, and target-specific DSP/SRAM mapping require a board or PDK flow.
