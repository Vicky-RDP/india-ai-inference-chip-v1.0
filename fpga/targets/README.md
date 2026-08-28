# Board targets

Add one directory per validated FPGA board. Keep board-specific constraints,
top-level RTL, tool scripts, and a short reproducibility note together. Start
from the board-neutral MMIO contract; do not fork the processor arithmetic for
individual boards.

An initial target pull request should include a smoke test that writes the
four-lane example from `docs/processor-interface.md` and reads back `4`.
