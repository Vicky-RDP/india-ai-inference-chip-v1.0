// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India Inference Chip contributors

module ii_dot_product #(
    parameter int LANES = 16,
    parameter int ACC_WIDTH = 32
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         valid_in,
    input  logic [LANES*8-1:0]           activations,
    input  logic [LANES*8-1:0]           weights,
    output logic                         valid_out,
    output logic signed [ACC_WIDTH-1:0] result
);

    integer lane;
    logic signed [ACC_WIDTH-1:0] sum;
    logic signed [7:0] activation;
    logic signed [7:0] weight;
    logic signed [15:0] product;

    always_comb begin
        sum = '0;
        for (lane = 0; lane < LANES; lane = lane + 1) begin
            activation = $signed(activations[lane*8 +: 8]);
            weight = $signed(weights[lane*8 +: 8]);
            product = activation * weight;
            sum = sum + product;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 1'b0;
            result <= '0;
        end else begin
            valid_out <= valid_in;
            if (valid_in) begin
                result <= sum;
            end
        end
    end

endmodule
