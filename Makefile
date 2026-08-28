.PHONY: test test-stream processor-test mmio-test matrix-test scratchpad-test dma-test dma-matrix-test integration-test fpga-smoke benchmark random-processor-test firmware-test reference unit random-test lint verilator-lint synth-report formal ci clean

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

matrix-test: $(BUILD_DIR)/ii_matrix_tile_stream_tb
	$(BUILD_DIR)/ii_matrix_tile_stream_tb

scratchpad-test: $(BUILD_DIR)/ii_scratchpad_tb
	$(BUILD_DIR)/ii_scratchpad_tb

dma-test: $(BUILD_DIR)/ii_scratchpad_dma_reader_tb
	$(BUILD_DIR)/ii_scratchpad_dma_reader_tb

dma-matrix-test: $(BUILD_DIR)/ii_dma_matrix_tile_tb
	$(BUILD_DIR)/ii_dma_matrix_tile_tb

fpga-smoke:
	bash fpga/targets/sim/smoke.sh

benchmark:
	python3 tools/benchmark.py $(BENCHMARK_ARGS)

integration-test: $(BUILD_DIR)/ii_matrix_tile_scratchpad_tb
	$(BUILD_DIR)/ii_matrix_tile_scratchpad_tb

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

$(BUILD_DIR)/ii_matrix_tile_stream_tb: rtl/ii_matrix_tile_stream.sv tb/ii_matrix_tile_stream_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_scratchpad_tb: rtl/ii_scratchpad.sv tb/ii_scratchpad_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_scratchpad_dma_reader_tb: rtl/ii_scratchpad.sv rtl/ii_scratchpad_dma_reader.sv tb/ii_scratchpad_dma_reader_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_dma_matrix_tile_tb: rtl/ii_matrix_tile_stream.sv rtl/ii_scratchpad.sv rtl/ii_scratchpad_dma_reader.sv tb/ii_dma_matrix_tile_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_matrix_tile_scratchpad_tb: rtl/ii_matrix_tile_stream.sv rtl/ii_scratchpad.sv tb/ii_matrix_tile_scratchpad_tb.sv
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
	$(SIM) $(SIM_FLAGS) -s ii_matrix_tile_stream -t null rtl/ii_matrix_tile_stream.sv
	$(SIM) $(SIM_FLAGS) -s ii_scratchpad -t null rtl/ii_scratchpad.sv
	$(SIM) $(SIM_FLAGS) -s ii_scratchpad_dma_reader -t null rtl/ii_scratchpad_dma_reader.sv
	$(SIM) $(SIM_FLAGS) -s ii_inference_processor_mmio -t null rtl/ii_dot_product.sv rtl/ii_dot_product_stream.sv rtl/ii_inference_processor.sv rtl/ii_inference_processor_mmio.sv

verilator-lint:
	@if command -v verilator >/dev/null 2>&1; then \
		verilator --lint-only --Wall --Wno-fatal --top-module ii_inference_processor \
			rtl/ii_dot_product.sv rtl/ii_dot_product_stream.sv rtl/ii_inference_processor.sv; \
	else \
		echo "verilator not installed; skipping optional Verilator lint"; \
	fi

synth-report:
	bash tools/synth_report.sh

formal:
	@if command -v sby >/dev/null 2>&1; then \
		sby -f formal/ii_matrix_tile.sby; \
	else \
		echo "symbiyosys not installed; skipping optional formal checks"; \
	fi

firmware-test:
	@mkdir -p $(BUILD_DIR)
	$(CC) -std=c11 -Wall -Wextra -Werror -pedantic -Ifirmware -c firmware/iaic_v1.c -o $(BUILD_DIR)/iaic_v1.o
	$(CC) -std=c11 -Wall -Wextra -Werror -pedantic -Ifirmware firmware/iaic_v1.c firmware/iaic_v1_test.c -o $(BUILD_DIR)/iaic_v1_test
	$(BUILD_DIR)/iaic_v1_test

ci: reference unit test test-stream processor-test mmio-test matrix-test scratchpad-test dma-test integration-test random-processor-test firmware-test random-test lint verilator-lint formal

clean:
	rm -rf $(BUILD_DIR)
