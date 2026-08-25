.PHONY: test reference clean

SIM ?= iverilog
SIM_FLAGS ?= -g2012 -Wall
BUILD_DIR ?= build

test: $(BUILD_DIR)/ii_dot_product_tb
	$(BUILD_DIR)/ii_dot_product_tb

$(BUILD_DIR)/ii_dot_product_tb: rtl/ii_dot_product.sv tb/ii_dot_product_tb.sv
	mkdir -p $(BUILD_DIR)
	$(SIM) $(SIM_FLAGS) -o $@ $^

reference:
	python3 tools/reference_model.py

clean:
	rm -rf $(BUILD_DIR)
