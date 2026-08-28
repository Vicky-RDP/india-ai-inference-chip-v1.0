// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

module ii_matrix_tile_stream_tb;
    localparam int M = 2;
    localparam int N = 2;
    localparam int K = 3;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic valid_in = 1'b0;
    logic ready_in;
    logic [M*K*8-1:0] activations = '0;
    logic [N*K*8-1:0] weights = '0;
    logic valid_out;
    logic ready_out = 1'b0;
    logic [M*N*32-1:0] result;

    always #5 clk = ~clk;

    ii_matrix_tile_stream #(.M(M), .N(N), .K(K)) dut (.*);

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        // A = [[1, 2, 3], [4, 5, 6]]
        // W rows represent output columns:
        // W = [[1, 0, -1], [2, 1, 0]]
        // Expected tile = [[-2, 4], [-2, 13]].
        @(negedge clk);
        activations = 48'h060504030201;
        weights = 48'h000102_ff0001;
        valid_in = 1'b1;
        if (!ready_in) $fatal(1, "matrix tile should be ready after reset");
        @(posedge clk);
        #1;
        valid_in = 1'b0;
        if (!valid_out) $fatal(1, "matrix tile result should be valid");
        if ($signed(result[31:0]) !== -2 ||
            $signed(result[63:32]) !== 4 ||
            $signed(result[95:64]) !== -2 ||
            $signed(result[127:96]) !== 13) begin
            $fatal(1, "unexpected matrix tile result: %h", result);
        end

        // Backpressure must hold the complete output tile stable.
        @(negedge clk);
        if (ready_in) $fatal(1, "matrix tile must stall while output is held");
        if ($signed(result[31:0]) !== -2 || $signed(result[127:96]) !== 13) begin
            $fatal(1, "stalled matrix tile result changed");
        end
        ready_out = 1'b1;
        @(posedge clk);
        #1;
        if (valid_out) $fatal(1, "matrix tile result should be consumed");
        $display("ii_matrix_tile_stream_tb: PASS");
        $finish;
    end
endmodule
