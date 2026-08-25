.PHONY: test test-stream reference unit lint ci clean

SIM ?= iverilog
SIM_FLAGS ?= -g2012 -Wall
BUILD_DIR ?= build

test: $(BUILD_DIR)/ii_dot_product_tb
	$(BUILD_DIR)/ii_dot_product_tb

test-stream: $(BUILD_DIR)/ii_dot_product_stream_tb
	$(BUILD_DIR)/ii_dot_product_stream_tb

$(BUILD_DIR)/ii_dot_product_tb: rtl/ii_dot_product.sv tb/ii_dot_product_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

$(BUILD_DIR)/ii_dot_product_stream_tb: rtl/ii_dot_product_stream.sv tb/ii_dot_product_stream_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

reference:
	python3 tools/reference_model.py

unit:
	python3 -m unittest discover -s tools -p 'test_*.py'

lint:
	$(SIM) $(SIM_FLAGS) -s ii_dot_product -t null rtl/ii_dot_product.sv
	$(SIM) $(SIM_FLAGS) -s ii_dot_product_stream -t null rtl/ii_dot_product_stream.sv

ci: reference unit test test-stream lint

clean:
	rm -rf $(BUILD_DIR)
