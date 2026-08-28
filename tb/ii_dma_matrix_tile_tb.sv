// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

module ii_dma_matrix_tile_tb;
    localparam int M = 2;
    localparam int N = 2;
    localparam int K = 3;
    localparam int ADDR_WIDTH = 4;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic mem_req_valid;
    logic mem_req_write;
    logic [ADDR_WIDTH-1:0] mem_req_addr;
    logic [31:0] mem_req_wdata;
    logic mem_req_ready;
    logic mem_rsp_valid;
    logic [31:0] mem_rsp_rdata;
    logic preload_active = 1'b0;
    logic preload_valid = 1'b0;
    logic preload_write = 1'b0;
    logic [ADDR_WIDTH-1:0] preload_addr = '0;
    logic [31:0] preload_wdata = '0;
    logic dma_req_valid;
    logic dma_req_write;
    logic [ADDR_WIDTH-1:0] dma_req_addr;
    logic [31:0] dma_req_wdata;
    logic dma_start = 1'b0;
    logic dma_start_ready;
    logic [ADDR_WIDTH-1:0] dma_base_addr = '0;
    logic [7:0] dma_length = '0;
    logic dma_busy;
    logic dma_done;
    logic dma_stream_valid;
    logic dma_stream_ready = 1'b1;
    logic [31:0] dma_stream_data;
    logic [31:0] staged_words [0:3];
    integer received = 0;

    logic tile_valid_in = 1'b0;
    logic tile_ready_in;
    logic [M*K*8-1:0] tile_activations = '0;
    logic [N*K*8-1:0] tile_weights = '0;
    logic tile_valid_out;
    logic tile_ready_out = 1'b1;
    logic [M*N*32-1:0] tile_result;

    always #5 clk = ~clk;

    always_comb begin
        if (preload_active) begin
            mem_req_valid = preload_valid;
            mem_req_write = preload_write;
            mem_req_addr = preload_addr;
            mem_req_wdata = preload_wdata;
        end else begin
            mem_req_valid = dma_req_valid;
            mem_req_write = dma_req_write;
            mem_req_addr = dma_req_addr;
            mem_req_wdata = dma_req_wdata;
        end
    end

    ii_scratchpad #(.ADDR_WIDTH(ADDR_WIDTH)) u_scratchpad (
        .clk(clk), .rst_n(rst_n), .req_valid(mem_req_valid), .req_write(mem_req_write),
        .req_addr(mem_req_addr), .req_wdata(mem_req_wdata), .req_ready(mem_req_ready),
        .rsp_valid(mem_rsp_valid), .rsp_rdata(mem_rsp_rdata)
    );

    ii_scratchpad_dma_reader #(.ADDR_WIDTH(ADDR_WIDTH), .LENGTH_WIDTH(8)) u_dma (
        .clk(clk), .rst_n(rst_n), .start(dma_start), .start_ready(dma_start_ready),
        .base_addr(dma_base_addr), .length(dma_length), .busy(dma_busy), .done(dma_done),
        .mem_req_valid(dma_req_valid), .mem_req_ready(mem_req_ready),
        .mem_req_write(dma_req_write), .mem_req_addr(dma_req_addr),
        .mem_req_wdata(dma_req_wdata), .mem_rsp_valid(mem_rsp_valid),
        .mem_rsp_rdata(mem_rsp_rdata), .stream_valid(dma_stream_valid),
        .stream_ready(dma_stream_ready), .stream_data(dma_stream_data)
    );

    ii_matrix_tile_stream #(.M(M), .N(N), .K(K)) u_tile (
        .clk(clk), .rst_n(rst_n), .valid_in(tile_valid_in), .ready_in(tile_ready_in),
        .activations(tile_activations), .weights(tile_weights),
        .valid_out(tile_valid_out), .ready_out(tile_ready_out), .result(tile_result)
    );

    task automatic preload_word(input logic [ADDR_WIDTH-1:0] address, input logic [31:0] value);
        begin
            @(negedge clk);
            preload_active = 1'b1;
            preload_valid = 1'b1;
            preload_write = 1'b1;
            preload_addr = address;
            preload_wdata = value;
            @(posedge clk); #1;
            preload_active = 1'b0;
            preload_valid = 1'b0;
            preload_write = 1'b0;
        end
    endtask

    always @(posedge clk) begin
        if (dma_stream_valid && dma_stream_ready) begin
            staged_words[received] = dma_stream_data;
            received = received + 1;
        end
    end

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;
        preload_word(4'd0, 32'h0003_0201);
        preload_word(4'd1, 32'h0006_0504);
        preload_word(4'd2, 32'h00ff_0001);
        preload_word(4'd3, 32'h0000_0102);

        @(negedge clk);
        dma_base_addr = 4'd0;
        dma_length = 8'd4;
        dma_start = 1'b1;
        if (!dma_start_ready) $fatal(1, "DMA should be ready to start");
        @(posedge clk); #1;
        dma_start = 1'b0;
        wait (!dma_busy);
        if (received !== 4 || !dma_done) begin
            $fatal(1, "DMA did not stage four words: received=%0d done=%b", received, dma_done);
        end

        tile_activations = {staged_words[1][23:0], staged_words[0][23:0]};
        tile_weights = {staged_words[3][23:0], staged_words[2][23:0]};
        @(negedge clk);
        tile_valid_in = 1'b1;
        if (!tile_ready_in) $fatal(1, "matrix tile should accept DMA data");
        @(posedge clk); #1;
        tile_valid_in = 1'b0;
        if (!tile_valid_out || tile_result !== 128'h0000_000d_ffff_fffe_0000_0004_ffff_fffe) begin
            $fatal(1, "unexpected DMA-to-tile result: %h", tile_result);
        end
        $display("ii_dma_matrix_tile_tb: PASS");
        $finish;
    end
endmodule
