# IAIC v1.0 scratchpad DMA contract

The first DMA primitive is a linear scratchpad reader. It moves contiguous
32-bit words from the word-addressed `ii_scratchpad` into a ready/valid stream.
This establishes the transport contract needed by a future matrix-tile loader;
burst scheduling, arbitration, and external DRAM are deliberately out of scope
for this first implementation.

## Reader transaction

The reader accepts a one-cycle `start` pulse while `busy` is low, with:

| Signal | Meaning |
| --- | --- |
| `base_addr` | first scratchpad word address |
| `length` | number of 32-bit words to transfer; must be non-zero |

It issues reads at `base_addr`, `base_addr + 1`, and so on. Every returned word
is presented through `stream_valid`, `stream_ready`, and `stream_data`. The
reader holds `stream_data` stable while the consumer applies backpressure.
`done` pulses for one clock when the final word is accepted. `busy` remains high
from accepted `start` until that final transfer.

The current reader assumes a one-cycle memory response and one outstanding
read. A later DMA version can preserve this stream contract while adding
outstanding requests or burst support.

The firmware-side `iaic_linear_dma_descriptor_t` mirrors this contract for
software experiments. It is validation-only today and must not be treated as a
stable hardware ABI until a DMA register map and external-memory policy are
approved.

## Tensor layout

The initial matrix tile uses contiguous row-major staging: all K bytes of
activation row 0, then row 1, followed by the weight rows. Each row is padded
to a 32-bit word boundary. A tensor descriptor must eventually add element
type, row stride, base address, and byte length; until then, callers must use
the explicit packed layouts in [matrix-tile.md](matrix-tile.md).
