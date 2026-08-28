# IAIC v1.0 benchmark methodology

The current benchmark target is the Python reference operator only. It is a
software correctness/performance sanity check and must not be compared with
future FPGA or ASIC throughput numbers without documenting the platform,
clock, workload, quantization, batching, and measurement method.

Run a deterministic sample with:

```bash
make benchmark BENCHMARK_ARGS="--lanes 16 --iterations 1000 --seed 20260828"
```

The JSON output reports per-operation minimum, median, mean, and maximum
latency in nanoseconds plus the corresponding model-operation rate. The seed
controls input generation; interpreter, CPU, and operating-system details
should be recorded alongside any published result.
