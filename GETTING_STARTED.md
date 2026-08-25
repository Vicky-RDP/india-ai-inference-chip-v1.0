# Getting Started

Welcome. This guide is for your first contribution to India AI Inference Chip v1.0.

## 1. Set up the tools

Required:

- Git
- Python 3.10 or newer
- GNU Make
- Icarus Verilog or Verilator for RTL simulation

On macOS with Homebrew:

```bash
brew install python icarus-verilog
```

On Ubuntu or Debian:

```bash
sudo apt-get update
sudo apt-get install python3 make iverilog
```

## 2. Clone and test

```bash
git clone https://github.com/Vicky-RDP/india-ai-inference-chip-v1.0.git
cd india-ai-inference-chip-v1.0
make reference
make test
```

The reference model defines the expected arithmetic. The RTL testbench checks the hardware implementation against known vectors.

## 3. Pick a contribution

Good first contributions include:

- Add edge-case vectors to the reference model and testbench.
- Add Verilator linting to CI.
- Document signed arithmetic and overflow behavior.
- Add a streaming valid/ready wrapper.
- Add synthesis scripts for a supported FPGA.
- Improve the onboarding documentation.
- Review an issue and identify hidden assumptions.

See [docs/workstreams.md](docs/workstreams.md) for larger areas of work.

## 4. Make a branch and open a pull request

```bash
git checkout -b your-name/short-description
git add .
git commit -m "Add a clear imperative description"
git push origin your-name/short-description
```

Then open a pull request on GitHub. The pull request template will ask what changed, how it was tested, and what tradeoffs remain.

## 5. Ask for help

Open a GitHub Discussion or Issue. Include the command you ran, the tool version, the expected result, and the actual result. Beginners are welcome; clear questions are valuable project contributions.
