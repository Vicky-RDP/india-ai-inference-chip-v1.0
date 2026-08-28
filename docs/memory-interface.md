# IAIC v1.0 scratchpad interface

`ii_scratchpad` is the first memory boundary for tiled inference. It models a
single-port synchronous word-addressed SRAM with a one-cycle response.

## Request and response

A request is accepted on a rising edge when `req_valid && req_ready` is high.
`req_ready` is currently tied high. The request fields are:

| Signal | Meaning |
| --- | --- |
| `req_write` | `1` for write, `0` for read |
| `req_addr` | word address, not byte address |
| `req_wdata` | write data |

Every accepted request produces `rsp_valid` on the following cycle. Read data
is returned on `rsp_rdata`; write responses return zero. The memory contents are
not reset so FPGA/ASIC synthesis tools can infer block RAM or SRAM rather than
resetting every storage bit.

The current primitive has no arbitration, byte enables, burst support, or DMA.
Those behaviors belong in the next memory-system decision record. The
matrix/scratchpad integration test demonstrates the intended sequencing for a
small tile.
