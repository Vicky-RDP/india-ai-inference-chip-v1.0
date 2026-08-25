// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India Inference Chip contributors

// One-entry elastic wrapper around a signed INT8 dot product.
// A request is accepted on a rising edge when valid_in && ready_in.
// The result remains stable while valid_out && !ready_out.
module ii_dot_product_stream #(
    parameter int LANES = 16,
    parameter int ACC_WIDTH = 32
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         valid_in,
    output logic                         ready_in,
    input  logic [LANES*8-1:0]           activations,
    input  logic [LANES*8-1:0]           weights,
    output logic                         valid_out,
    input  logic                         ready_out,
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
                result <= sum;
            end
        end
    end

endmodule

