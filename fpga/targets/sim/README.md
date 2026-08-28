# Board-neutral FPGA smoke target

This target does not claim a physical board. It runs the host MMIO, matrix,
scratchpad, DMA, and DMA-to-matrix smoke tests that a future FPGA bitstream
must reproduce.

Run it with:

```bash
make fpga-smoke
```

When a board-specific target is added, retain this smoke gate and add the
board's bitstream build, timing/utilization report, and host transport test.
