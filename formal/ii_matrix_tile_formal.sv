// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

// Lightweight SymbiYosys harness for the matrix tile's stream contract.
module ii_matrix_tile_formal;
    localparam int M = 2;
    localparam int N = 2;
    localparam int K = 3;

    (* gclk *) logic clk;
    (* anyseq *) logic rst_n;
    (* anyseq *) logic valid_in;
    (* anyseq *) logic ready_out;
    (* anyseq *) logic [M*K*8-1:0] activations;
    (* anyseq *) logic [N*K*8-1:0] weights;
    logic ready_in;
    logic valid_out;
    logic [M*N*32-1:0] result;

    ii_matrix_tile_stream #(.M(M), .N(N), .K(K)) dut (.*);

    initial assume(rst_n);

    always @(posedge clk) begin
        // Keep the proof focused on the post-reset stream contract.
        assume(rst_n);
        if ($past(valid_out && !ready_out)) begin
            assert(valid_out);
            assert(result == $past(result));
        end
    end
endmodule
