// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

// Simple single-port scratchpad interface for the IAIC v1.0 memory boundary.
//
// The memory array is deliberately not reset so synthesis tools can infer
// block RAM/SRAM. A request is accepted on every clock while req_valid is
// asserted; a response is returned one clock later for both reads and writes.
module ii_scratchpad #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 8
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  req_valid,
    input  logic                  req_write,
    input  logic [ADDR_WIDTH-1:0] req_addr,
    input  logic [DATA_WIDTH-1:0] req_wdata,
    output logic                  req_ready,
    output logic                  rsp_valid,
    output logic [DATA_WIDTH-1:0] rsp_rdata
);

    localparam int DEPTH = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    assign req_ready = 1'b1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rsp_valid <= 1'b0;
            rsp_rdata <= '0;
        end else begin
            rsp_valid <= req_valid && req_ready;
            if (req_valid && req_ready) begin
                if (req_write) begin
                    memory[req_addr] <= req_wdata;
                    rsp_rdata <= '0;
                end else begin
                    rsp_rdata <= memory[req_addr];
                end
            end
        end
    end

endmodule
