// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

// Linear scratchpad-to-stream DMA reader.
//
// The reader keeps one memory request outstanding at a time and holds each
// returned word until the downstream stream accepts it. This is a small,
// portable baseline for a future tiled-inference DMA engine.
module ii_scratchpad_dma_reader #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 8,
    parameter int LENGTH_WIDTH = 16
) (
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic                      start,
    output logic                      start_ready,
    input  logic [ADDR_WIDTH-1:0]     base_addr,
    input  logic [LENGTH_WIDTH-1:0]   length,
    output logic                      busy,
    output logic                      done,
    output logic                      mem_req_valid,
    input  logic                      mem_req_ready,
    output logic                      mem_req_write,
    output logic [ADDR_WIDTH-1:0]     mem_req_addr,
    output logic [DATA_WIDTH-1:0]     mem_req_wdata,
    input  logic                      mem_rsp_valid,
    input  logic [DATA_WIDTH-1:0]     mem_rsp_rdata,
    output logic                      stream_valid,
    input  logic                      stream_ready,
    output logic [DATA_WIDTH-1:0]     stream_data
);

    typedef enum logic [1:0] {IDLE, REQUEST, WAIT_RESPONSE, OUTPUT} state_t;
    state_t state;
    logic [ADDR_WIDTH-1:0] current_addr;
    logic [LENGTH_WIDTH-1:0] remaining;

    assign start_ready = (state == IDLE);
    assign mem_req_valid = (state == REQUEST);
    assign mem_req_write = 1'b0;
    assign mem_req_addr = current_addr;
    assign mem_req_wdata = '0;
    assign stream_valid = (state == OUTPUT);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            current_addr <= '0;
            remaining   <= '0;
            busy        <= 1'b0;
            done        <= 1'b0;
            stream_data <= '0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    if (start && start_ready && (length != 0)) begin
                        current_addr <= base_addr;
                        remaining <= length;
                        busy <= 1'b1;
                        state <= REQUEST;
                    end
                end
                REQUEST: begin
                    if (mem_req_ready) begin
                        state <= WAIT_RESPONSE;
                    end
                end
                WAIT_RESPONSE: begin
                    if (mem_rsp_valid) begin
                        stream_data <= mem_rsp_rdata;
                        state <= OUTPUT;
                    end
                end
                OUTPUT: begin
                    if (stream_ready) begin
                        if (remaining == 1) begin
                            remaining <= '0;
                            busy <= 1'b0;
                            done <= 1'b1;
                            state <= IDLE;
                        end else begin
                            remaining <= remaining - 1'b1;
                            current_addr <= current_addr + 1'b1;
                            state <= REQUEST;
                        end
                    end
                end
                default: begin
                    state <= IDLE;
                    busy <= 1'b0;
                end
            endcase
        end
    end

endmodule
