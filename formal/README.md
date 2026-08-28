# Optional formal checks

The SymbiYosys harness checks the most important ready/valid safety property
of the matrix tile: once an output is stalled, it remains valid and its result
does not change. Run it with:

```bash
make formal
```

The target skips with a clear message when `sby` is not installed. The current
formal file intentionally focuses on stream stability; arithmetic equivalence
remains covered by the Python golden model and directed RTL tests until a
solver-backed numeric proof is added.

The formal harness is intentionally separate from synthesizable RTL and is not
used to make a hardware sign-off claim. A passing bounded proof is evidence for
the stated property at its configured depth, not a substitute for full
assertion, CDC, or implementation sign-off.
