// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

module ii_scratchpad_tb;
    localparam int ADDR_WIDTH = 4;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic req_valid = 1'b0;
    logic req_write = 1'b0;
    logic [ADDR_WIDTH-1:0] req_addr = '0;
    logic [31:0] req_wdata = '0;
    logic req_ready;
    logic rsp_valid;
    logic [31:0] rsp_rdata;

    always #5 clk = ~clk;

    ii_scratchpad #(.ADDR_WIDTH(ADDR_WIDTH)) dut (.*);

    task automatic write_word(input logic [ADDR_WIDTH-1:0] address, input logic [31:0] value);
        begin
            @(negedge clk);
            req_valid = 1'b1;
            req_write = 1'b1;
            req_addr = address;
            req_wdata = value;
            if (!req_ready) $fatal(1, "scratchpad should accept writes");
            @(posedge clk);
            #1;
            if (!rsp_valid || rsp_rdata !== 32'h0) $fatal(1, "write response failed");
            req_valid = 1'b0;
            req_write = 1'b0;
        end
    endtask

    task automatic read_word(input logic [ADDR_WIDTH-1:0] address, input logic [31:0] expected);
        begin
            @(negedge clk);
            req_valid = 1'b1;
            req_write = 1'b0;
            req_addr = address;
            @(posedge clk);
            #1;
            if (!rsp_valid || rsp_rdata !== expected) begin
                $fatal(1, "read %h: got %h expected %h", address, rsp_rdata, expected);
            end
            req_valid = 1'b0;
        end
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;
        write_word(4'h5, 32'h1a1c_2026);
        write_word(4'hf, 32'hc0de_cafe);
        write_word(4'h0, 32'h0000_0000);
        read_word(4'h5, 32'h1a1c_2026);
        read_word(4'hf, 32'hc0de_cafe);
        read_word(4'h0, 32'h0000_0000);
        $display("ii_scratchpad_tb: PASS");
        $finish;
    end
endmodule
