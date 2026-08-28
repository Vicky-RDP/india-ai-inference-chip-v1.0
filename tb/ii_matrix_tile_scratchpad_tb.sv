// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

module ii_matrix_tile_scratchpad_tb;
    localparam int M = 2;
    localparam int N = 2;
    localparam int K = 3;
    localparam int ADDR_WIDTH = 4;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic mem_req_valid = 1'b0;
    logic mem_req_write = 1'b0;
    logic [ADDR_WIDTH-1:0] mem_req_addr = '0;
    logic [31:0] mem_req_wdata = '0;
    logic mem_req_ready;
    logic mem_rsp_valid;
    logic [31:0] mem_rsp_rdata;

    logic tile_valid_in = 1'b0;
    logic tile_ready_in;
    logic [M*K*8-1:0] tile_activations = '0;
    logic [N*K*8-1:0] tile_weights = '0;
    logic tile_valid_out;
    logic tile_ready_out = 1'b1;
    logic [M*N*32-1:0] tile_result;

    always #5 clk = ~clk;

    ii_scratchpad #(.ADDR_WIDTH(ADDR_WIDTH)) u_scratchpad (
        .clk(clk), .rst_n(rst_n), .req_valid(mem_req_valid), .req_write(mem_req_write),
        .req_addr(mem_req_addr), .req_wdata(mem_req_wdata), .req_ready(mem_req_ready),
        .rsp_valid(mem_rsp_valid), .rsp_rdata(mem_rsp_rdata)
    );

    ii_matrix_tile_stream #(.M(M), .N(N), .K(K)) u_tile (
        .clk(clk), .rst_n(rst_n), .valid_in(tile_valid_in), .ready_in(tile_ready_in),
        .activations(tile_activations), .weights(tile_weights),
        .valid_out(tile_valid_out), .ready_out(tile_ready_out), .result(tile_result)
    );

    task automatic write_word(input logic [ADDR_WIDTH-1:0] address, input logic [31:0] value);
        begin
            @(negedge clk);
            mem_req_valid = 1'b1;
            mem_req_write = 1'b1;
            mem_req_addr = address;
            mem_req_wdata = value;
            @(posedge clk);
            #1;
            if (!mem_rsp_valid) $fatal(1, "scratchpad write response missing");
            mem_req_valid = 1'b0;
            mem_req_write = 1'b0;
        end
    endtask

    task automatic read_word(input logic [ADDR_WIDTH-1:0] address, input logic [31:0] expected);
        begin
            @(negedge clk);
            mem_req_valid = 1'b1;
            mem_req_write = 1'b0;
            mem_req_addr = address;
            @(posedge clk);
            #1;
            if (!mem_rsp_valid || mem_rsp_rdata !== expected) begin
                $fatal(1, "scratchpad read %h: got %h expected %h", address, mem_rsp_rdata, expected);
            end
            mem_req_valid = 1'b0;
        end
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        // Stage A rows at words 0-1 and W rows at words 2-3.
        write_word(4'h0, 32'h0003_0201);
        write_word(4'h1, 32'h0006_0504);
        write_word(4'h2, 32'h00ff_0001);
        write_word(4'h3, 32'h0000_0102);

        read_word(4'h0, 32'h0003_0201);
        read_word(4'h1, 32'h0006_0504);
        read_word(4'h2, 32'h00ff_0001);
        read_word(4'h3, 32'h0000_0102);

        tile_activations = 48'h060504030201;
        tile_weights = 48'h000102_ff0001;
        @(negedge clk);
        tile_valid_in = 1'b1;
        if (!tile_ready_in) $fatal(1, "tile should accept staged rows");
        @(posedge clk);
        #1;
        tile_valid_in = 1'b0;
        if (!tile_valid_out || tile_result !== 128'h0000_000d_ffff_fffe_0000_0004_ffff_fffe) begin
            $fatal(1, "unexpected end-to-end tile result: %h", tile_result);
        end

        write_word(4'h4, tile_result[31:0]);
        write_word(4'h5, tile_result[63:32]);
        write_word(4'h6, tile_result[95:64]);
        write_word(4'h7, tile_result[127:96]);
        read_word(4'h4, 32'hffff_fffe);
        read_word(4'h5, 32'h0000_0004);
        read_word(4'h6, 32'hffff_fffe);
        read_word(4'h7, 32'h0000_000d);
        $display("ii_matrix_tile_scratchpad_tb: PASS");
        $finish;
    end
endmodule
