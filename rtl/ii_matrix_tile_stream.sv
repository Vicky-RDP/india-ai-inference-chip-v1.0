// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

// Parameterized streamed INT8 matrix tile.
//
// For each accepted command, this block computes M*N outputs. Each output is
// the dot product of one activation row and one weight row, each with K signed
// INT8 terms. Lane 0 of every packed row is in the least-significant byte.
// The output tile is packed output [row][column], with output 0 in the
// least-significant ACC_WIDTH bits.
module ii_matrix_tile_stream #(
    parameter int M = 2,
    parameter int N = 2,
    parameter int K = 16,
    parameter int ACC_WIDTH = 32
) (
    input  logic                                  clk,
    input  logic                                  rst_n,
    input  logic                                  valid_in,
    output logic                                  ready_in,
    input  logic [M*K*8-1:0]                      activations,
    input  logic [N*K*8-1:0]                      weights,
    output logic                                  valid_out,
    input  logic                                  ready_out,
    output logic [M*N*ACC_WIDTH-1:0]             result
);

    logic signed [ACC_WIDTH-1:0] tile_sum [0:M*N-1];
    logic [M*N*ACC_WIDTH-1:0] computed_tile;
    logic signed [7:0] activation_value;
    logic signed [7:0] weight_value;
    logic signed [15:0] product;
    integer row;
    integer column;
    integer lane;
    integer output_index;

    always_comb begin
        for (output_index = 0; output_index < M*N; output_index = output_index + 1) begin
            tile_sum[output_index] = '0;
        end

        for (row = 0; row < M; row = row + 1) begin
            for (column = 0; column < N; column = column + 1) begin
                for (lane = 0; lane < K; lane = lane + 1) begin
                    activation_value = $signed(activations[(row*K + lane)*8 +: 8]);
                    weight_value = $signed(weights[(column*K + lane)*8 +: 8]);
                    product = activation_value * weight_value;
                    tile_sum[row*N + column] = tile_sum[row*N + column] + product;
                end
            end
        end

        computed_tile = '0;
        for (output_index = 0; output_index < M*N; output_index = output_index + 1) begin
            computed_tile[output_index*ACC_WIDTH +: ACC_WIDTH] = tile_sum[output_index];
        end
    end

    always_comb begin
        ready_in = !valid_out || ready_out;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 1'b0;
            result <= '0;
        end else if (ready_in) begin
            valid_out <= valid_in;
            if (valid_in) begin
                result <= computed_tile;
            end
        end
    end

endmodule
