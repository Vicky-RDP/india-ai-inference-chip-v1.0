// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

module ii_inference_processor_mmio_tb;
    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic bus_valid = 1'b0;
    logic bus_write = 1'b0;
    logic [7:0] bus_addr = '0;
    logic [31:0] bus_wdata = '0;
    logic bus_ready;
    logic bus_rsp_valid;
    logic [31:0] bus_rdata;
    logic irq;

    always #5 clk = ~clk;

    ii_inference_processor_mmio #(.LANES(4)) dut (.*);

    task automatic write_word(input logic [7:0] address, input logic [31:0] value);
        begin
            @(negedge clk);
            bus_addr = address;
            bus_wdata = value;
            bus_write = 1'b1;
            bus_valid = 1'b1;
            while (!bus_ready) @(negedge clk);
            @(posedge clk);
            #1;
            if (!bus_rsp_valid) $fatal(1, "missing write response at %h", address);
            bus_valid = 1'b0;
            bus_write = 1'b0;
        end
    endtask

    task automatic read_word(input logic [7:0] address, input logic [31:0] expected);
        begin
            @(negedge clk);
            bus_addr = address;
            bus_wdata = '0;
            bus_write = 1'b0;
            bus_valid = 1'b1;
            @(posedge clk);
            #1;
            if (!bus_rsp_valid) $fatal(1, "missing read response at %h", address);
            if (bus_rdata !== expected) begin
                $fatal(1, "read %h: got %h expected %h", address, bus_rdata, expected);
            end
            bus_valid = 1'b0;
        end
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        write_word(8'h00, 32'h0000_0003);
        write_word(8'h10, 32'hfc03_fe01);
        write_word(8'h20, 32'hfbfc_0302);
        write_word(8'h30, 32'h0000_0001);

        // Allow the queued command to reach the dot-product result entry.
        @(posedge clk);
        #1;
        read_word(8'h08, 32'd4);
        if (!irq) $fatal(1, "reading the result should set completion IRQ");
        read_word(8'h10, 32'hfc03_fe01);
        read_word(8'h20, 32'hfbfc_0302);
        $display("ii_inference_processor_mmio_tb: PASS");
        $finish;
    end
endmodule
