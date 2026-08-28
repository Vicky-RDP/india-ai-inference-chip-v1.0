.PHONY: test test-stream processor-test mmio-test random-processor-test firmware-test reference unit random-test lint verilator-lint synth-report ci clean

SIM ?= iverilog
SIM_FLAGS ?= -g2012 -Wall
BUILD_DIR ?= build

test: $(BUILD_DIR)/ii_dot_product_tb
	$(BUILD_DIR)/ii_dot_product_tb

test-stream: $(BUILD_DIR)/ii_dot_product_stream_tb
	$(BUILD_DIR)/ii_dot_product_stream_tb

processor-test: $(BUILD_DIR)/ii_inference_processor_tb
	$(BUILD_DIR)/ii_inference_processor_tb

mmio-test: $(BUILD_DIR)/ii_inference_processor_mmio_tb
	$(BUILD_DIR)/ii_inference_processor_mmio_tb

random-processor-test:
	python3 tools/test_processor_random.py

$(BUILD_DIR)/ii_dot_product_tb: rtl/ii_dot_product.sv tb/ii_dot_product_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_dot_product_stream_tb: rtl/ii_dot_product_stream.sv tb/ii_dot_product_stream_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_inference_processor_tb: rtl/ii_dot_product.sv rtl/ii_dot_product_stream.sv rtl/ii_inference_processor.sv tb/ii_inference_processor_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_inference_processor_mmio_tb: rtl/ii_dot_product.sv rtl/ii_dot_product_stream.sv rtl/ii_inference_processor.sv rtl/ii_inference_processor_mmio.sv tb/ii_inference_processor_mmio_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

reference:
	python3 tools/reference_model.py

unit:
	python3 -m unittest discover -s tools -p 'test_*.py'

random-test:
	python3 tools/test_rtl_random.py

lint:
	$(SIM) $(SIM_FLAGS) -s ii_dot_product -t null rtl/ii_dot_product.sv
	$(SIM) $(SIM_FLAGS) -s ii_dot_product_stream -t null rtl/ii_dot_product_stream.sv
	$(SIM) $(SIM_FLAGS) -s ii_inference_processor -t null rtl/ii_dot_product.sv rtl/ii_dot_product_stream.sv rtl/ii_inference_processor.sv

verilator-lint:
	@if command -v verilator >/dev/null 2>&1; then \
		verilator --lint-only --Wall --Wno-fatal --top-module ii_inference_processor \
			rtl/ii_dot_product.sv rtl/ii_dot_product_stream.sv rtl/ii_inference_processor.sv; \
	else \
		echo "verilator not installed; skipping optional Verilator lint"; \
	fi

synth-report:
	bash tools/synth_report.sh

firmware-test:
	@mkdir -p $(BUILD_DIR)
	$(CC) -std=c11 -Wall -Wextra -Werror -pedantic -Ifirmware -c firmware/iaic_v1.c -o $(BUILD_DIR)/iaic_v1.o

ci: reference unit test test-stream processor-test mmio-test random-processor-test firmware-test random-test lint verilator-lint

clean:
	rm -rf $(BUILD_DIR)
