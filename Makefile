.PHONY: test test-stream processor-test reference unit random-test lint ci clean

SIM ?= iverilog
SIM_FLAGS ?= -g2012 -Wall
BUILD_DIR ?= build

test: $(BUILD_DIR)/ii_dot_product_tb
	$(BUILD_DIR)/ii_dot_product_tb

test-stream: $(BUILD_DIR)/ii_dot_product_stream_tb
	$(BUILD_DIR)/ii_dot_product_stream_tb

processor-test: $(BUILD_DIR)/ii_inference_processor_tb
	$(BUILD_DIR)/ii_inference_processor_tb

$(BUILD_DIR)/ii_dot_product_tb: rtl/ii_dot_product.sv tb/ii_dot_product_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_dot_product_stream_tb: rtl/ii_dot_product_stream.sv tb/ii_dot_product_stream_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_inference_processor_tb: rtl/ii_dot_product.sv rtl/ii_dot_product_stream.sv rtl/ii_inference_processor.sv tb/ii_inference_processor_tb.sv
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

ci: reference unit test test-stream processor-test random-test lint

clean:
	rm -rf $(BUILD_DIR)
