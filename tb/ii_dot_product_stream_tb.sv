// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India Inference Chip contributors

module ii_dot_product_stream_tb;
    localparam int LANES = 4;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic valid_in = 1'b0;
    logic ready_in;
    logic [LANES*8-1:0] activations = '0;
    logic [LANES*8-1:0] weights = '0;
    logic valid_out;
    logic ready_out = 1'b0;
    logic signed [31:0] result;

    always #5 clk = ~clk;

    ii_dot_product_stream #(.LANES(LANES)) dut (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in), .ready_in(ready_in),
        .activations(activations), .weights(weights), .valid_out(valid_out),
        .ready_out(ready_out), .result(result)
    );

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        @(negedge clk);
        activations = {8'hfc, 8'h03, 8'hfe, 8'h01};
        weights = {8'hfb, 8'hfc, 8'h03, 8'h02};
        valid_in = 1'b1;
        if (!ready_in) $fatal(1, "input should be ready after reset");
        @(posedge clk);
        #1;
        valid_in = 1'b0;
        if (!valid_out) $fatal(1, "output should be valid after acceptance");
        if (result !== 4) $fatal(1, "expected 4, got %0d", result);

        // Backpressure must hold both valid and data.
        @(negedge clk);
        if (ready_in) $fatal(1, "input must not be ready while output is stalled");
        if (result !== 4) $fatal(1, "stalled result changed");
        ready_out = 1'b1;
        @(posedge clk);
        #1;
        if (valid_out) $fatal(1, "output should be consumed");

        // Max/min signed values exercise sign extension.
        @(negedge clk);
        activations = {8'hff, 8'h00, 8'h80, 8'h7f};
        weights = {8'h01, 8'h00, 8'h80, 8'h7f};
        valid_in = 1'b1;
        @(posedge clk);
        #1;
        valid_in = 1'b0;
        if (!valid_out || result !== 32512) $fatal(1, "signed edge vector failed: %0d", result);
        $display("ii_dot_product_stream_tb: PASS");
        $finish;
    end
endmodule

