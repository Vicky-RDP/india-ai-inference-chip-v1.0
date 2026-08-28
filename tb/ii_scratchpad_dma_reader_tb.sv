// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

module ii_scratchpad_dma_reader_tb;
    localparam int ADDR_WIDTH = 5;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic start = 1'b0;
    logic start_ready;
    logic [ADDR_WIDTH-1:0] base_addr = '0;
    logic [7:0] length = '0;
    logic busy;
    logic done;
    logic mem_req_valid;
    logic mem_req_ready;
    logic mem_req_write;
    logic [ADDR_WIDTH-1:0] mem_req_addr;
    logic [31:0] mem_req_wdata;
    logic preload_active = 1'b0;
    logic preload_valid = 1'b0;
    logic preload_write = 1'b0;
    logic [ADDR_WIDTH-1:0] preload_addr = '0;
    logic [31:0] preload_wdata = '0;
    logic dma_req_valid;
    logic dma_req_write;
    logic [ADDR_WIDTH-1:0] dma_req_addr;
    logic [31:0] dma_req_wdata;
    logic mem_rsp_valid;
    logic [31:0] mem_rsp_rdata;
    logic stream_valid;
    logic stream_ready = 1'b0;
    logic [31:0] stream_data;

    integer received = 0;
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
        .clk(clk), .rst_n(rst_n), .start(start), .start_ready(start_ready),
        .base_addr(base_addr), .length(length), .busy(busy), .done(done),
        .mem_req_valid(dma_req_valid), .mem_req_ready(mem_req_ready),
        .mem_req_write(dma_req_write), .mem_req_addr(dma_req_addr),
        .mem_req_wdata(dma_req_wdata), .mem_rsp_valid(mem_rsp_valid),
        .mem_rsp_rdata(mem_rsp_rdata), .stream_valid(stream_valid),
        .stream_ready(stream_ready), .stream_data(stream_data)
    );

    task automatic write_word(input logic [ADDR_WIDTH-1:0] address, input logic [31:0] value);
        begin
            @(negedge clk);
            preload_active = 1'b1;
            preload_valid = 1'b1;
            preload_write = 1'b1;
            preload_addr = address;
            preload_wdata = value;
            @(posedge clk); #1;
            if (!mem_rsp_valid) $fatal(1, "scratchpad write response missing");
            preload_active = 1'b0;
            preload_valid = 1'b0;
            preload_write = 1'b0;
        end
    endtask

    always @(posedge clk) begin
        if (stream_valid && stream_ready) begin
            if (stream_data !== (32'h1000_0003 + received)) begin
                $fatal(1, "DMA word %0d: got %h", received, stream_data);
            end
            received = received + 1;
        end
    end

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;
        write_word(5'd3, 32'h1000_0003);
        write_word(5'd4, 32'h1000_0004);
        write_word(5'd5, 32'h1000_0005);
        write_word(5'd6, 32'h1000_0006);
        write_word(5'd7, 32'h1000_0007);

        @(negedge clk);
        base_addr = 5'd3;
        length = 8'd5;
        start = 1'b1;
        if (!start_ready) $fatal(1, "DMA should be idle after reset");
        @(posedge clk); #1;
        start = 1'b0;

        // The consumer stalls every other cycle and must still receive order.
        repeat (20) begin
            @(negedge clk);
            stream_ready = !stream_ready;
        end
        wait (!busy);
        if (received !== 5) $fatal(1, "DMA received %0d words", received);
        if (busy) $fatal(1, "DMA should be idle after completion");
        $display("ii_scratchpad_dma_reader_tb: PASS");
        $finish;
    end
endmodule
