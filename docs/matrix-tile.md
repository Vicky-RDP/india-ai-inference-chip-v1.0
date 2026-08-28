# IAIC v1.0 matrix tile contract

`ii_matrix_tile_stream` computes an M×N output tile from M activation rows and
N weight rows. Every row has K signed INT8 values. For output row `m` and
column `n`:

```text
output[m][n] = sum(activations[m][k] * weights[n][k] for k in 0..K-1)
```

The default implementation is parameterized and uses `M=2`, `N=2`, and
`K=16` when no overrides are supplied. It produces one registered output tile
per accepted command and holds the complete result stable while downstream
backpressure is asserted.

## Packing

For every row, lane 0 occupies the least-significant byte:

```text
activations[(m*K + k)*8 +: 8] = activation[m][k]
weights[(n*K + k)*8 +: 8]        = weight[n][k]
result[(m*N + n)*ACC_WIDTH +: ACC_WIDTH] = output[m][n]
```

The output order is row-major. All products are signed 16-bit products and
are accumulated into the signed `ACC_WIDTH` result. The v1.0 reference model
raises an overflow error when a result cannot fit the selected accumulator;
the RTL currently preserves the low `ACC_WIDTH` bits, so overflow policy must
be made explicit before a production matrix engine is frozen.

The Python golden model is in [tools/matrix_model.py](../tools/matrix_model.py)
and the initial RTL test vector is in
[tb/ii_matrix_tile_stream_tb.sv](../tb/ii_matrix_tile_stream_tb.sv).

The first memory-to-compute-to-memory example is
[tb/ii_matrix_tile_scratchpad_tb.sv](../tb/ii_matrix_tile_scratchpad_tb.sv).
It stages rows in the scratchpad, submits the tile, and stores the four output
words back into the scratchpad. This is a verification example; DMA and
software scheduling are still future work.
