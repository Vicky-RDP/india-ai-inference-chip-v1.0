// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India Inference Chip contributors

module ii_dot_product_tb;
    localparam int LANES = 4;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic valid_in = 1'b0;
    logic [LANES*8-1:0] activations = '0;
    logic [LANES*8-1:0] weights = '0;
    logic valid_out;
    logic signed [31:0] result;

    always #5 clk = ~clk;

    ii_dot_product #(.LANES(LANES)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .activations(activations),
        .weights(weights),
        .valid_out(valid_out),
        .result(result)
    );

    task automatic drive_and_check(
        input integer expected,
        input logic [LANES*8-1:0] a,
        input logic [LANES*8-1:0] w
    );
        begin
            @(negedge clk);
            activations = a;
            weights = w;
            valid_in = 1'b1;
            @(negedge clk);
            valid_in = 1'b0;
            #1;
            if (!valid_out) $fatal(1, "valid_out was not asserted");
            if (result !== expected) $fatal(1, "expected %0d, got %0d", expected, result);
        end
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        drive_and_check(1*2 + (-2)*3 + 3*(-4) + (-4)*(-5),
                        {8'hfc, 8'h03, 8'hfe, 8'h01},
                        {8'hfb, 8'hfc, 8'h03, 8'h02});
        drive_and_check(127*127 + (-128)*(-128) + 0 + (-1)*1,
                        {8'hff, 8'h00, 8'h80, 8'h7f},
                        {8'h01, 8'h00, 8'h80, 8'h7f});

        @(negedge clk);
        if (valid_out) $fatal(1, "valid_out should be low without valid_in");
        $display("ii_dot_product_tb: PASS");
        $finish;
    end
endmodule
