#!/usr/bin/env python3
"""Reproducible software-side latency benchmark for the IAIC operator model."""

from __future__ import annotations

import argparse
import json
import random
import statistics
import time

from iaic_operator import int8_dot_product


def run_benchmark(lanes: int, iterations: int, seed: int) -> dict[str, float | int]:
    if lanes < 1 or iterations < 1:
        raise ValueError("lanes and iterations must be positive")
    rng = random.Random(seed)
    vectors = [
        (
            [rng.randint(-128, 127) for _ in range(lanes)],
            [rng.randint(-128, 127) for _ in range(lanes)],
        )
        for _ in range(iterations)
    ]

    samples_ns = []
    for activations, weights in vectors:
        start_ns = time.perf_counter_ns()
        int8_dot_product(activations, weights)
        samples_ns.append(time.perf_counter_ns() - start_ns)

    mean_ns = statistics.mean(samples_ns)
    return {
        "lanes": lanes,
        "iterations": iterations,
        "seed": seed,
        "min_ns": min(samples_ns),
        "median_ns": statistics.median(samples_ns),
        "mean_ns": mean_ns,
        "max_ns": max(samples_ns),
        "ops_per_second": 1_000_000_000 / mean_ns,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lanes", type=int, default=16)
    parser.add_argument("--iterations", type=int, default=1000)
    parser.add_argument("--seed", type=int, default=20260828)
    args = parser.parse_args()
    print(json.dumps(run_benchmark(args.lanes, args.iterations, args.seed), indent=2))


if __name__ == "__main__":
    main()
