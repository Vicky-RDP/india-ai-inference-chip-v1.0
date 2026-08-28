// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

module ii_inference_processor_tb;
    localparam int LANES = 4;

    logic clk = 1'b0;
    logic rst_n = 1'b0;

    logic csr_valid = 1'b0;
    logic csr_write = 1'b0;
    logic [3:0] csr_addr = '0;
    logic [31:0] csr_wdata = '0;
    logic csr_ready;
    logic csr_rsp_valid;
    logic [31:0] csr_rdata;

    logic cmd_valid = 1'b0;
    logic cmd_ready;
    logic [LANES*8-1:0] cmd_activations = '0;
    logic [LANES*8-1:0] cmd_weights = '0;
    logic result_valid;
    logic result_ready = 1'b0;
    logic signed [31:0] result;
    logic busy;
    logic done;
    logic irq;

    always #5 clk = ~clk;

    ii_inference_processor #(.LANES(LANES)) dut (
        .clk             (clk),
        .rst_n           (rst_n),
        .csr_valid       (csr_valid),
        .csr_write       (csr_write),
        .csr_addr        (csr_addr),
        .csr_wdata       (csr_wdata),
        .csr_ready       (csr_ready),
        .csr_rsp_valid   (csr_rsp_valid),
        .csr_rdata       (csr_rdata),
        .cmd_valid       (cmd_valid),
        .cmd_ready       (cmd_ready),
        .cmd_activations (cmd_activations),
        .cmd_weights     (cmd_weights),
        .result_valid    (result_valid),
        .result_ready    (result_ready),
        .result          (result),
        .busy            (busy),
        .done            (done),
        .irq             (irq)
    );

    task automatic csr_write_word(input logic [3:0] address, input logic [31:0] value);
        begin
            @(negedge clk);
            csr_addr = address;
            csr_wdata = value;
            csr_write = 1'b1;
            csr_valid = 1'b1;
            if (!csr_ready) $fatal(1, "CSR should always be ready");
            @(posedge clk);
            #1;
            if (!csr_rsp_valid) $fatal(1, "missing CSR write response");
            csr_valid = 1'b0;
            csr_write = 1'b0;
        end
    endtask

    task automatic csr_read_word(input logic [3:0] address, input logic [31:0] expected);
        begin
            @(negedge clk);
            csr_addr = address;
            csr_wdata = '0;
            csr_write = 1'b0;
            csr_valid = 1'b1;
            @(posedge clk);
            #1;
            if (!csr_rsp_valid) $fatal(1, "missing CSR read response");
            if (csr_rdata !== expected) begin
                $fatal(1, "CSR address %h: got %h expected %h", address, csr_rdata, expected);
            end
            csr_valid = 1'b0;
        end
    endtask

    task automatic submit_command(
        input logic [LANES*8-1:0] activations,
        input logic [LANES*8-1:0] weights
    );
        begin
            @(negedge clk);
            cmd_activations = activations;
            cmd_weights = weights;
            cmd_valid = 1'b1;
            if (!cmd_ready) $fatal(1, "processor command queue unexpectedly full");
            @(posedge clk);
            #1;
            cmd_valid = 1'b0;
        end
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        // CONTROL: enable command acceptance and completion interrupt.
        csr_write_word(4'h0, 32'h0000_0003);
        csr_read_word(4'hc, 32'h0001_0000);

        // Submit one signed INT8 command: 1*2 + (-2)*3 + 3*(-4) + (-4)*(-5) = 4.
        result_ready = 1'b0;
        submit_command({8'hfc, 8'h03, 8'hfe, 8'h01}, {8'hfb, 8'hfc, 8'h03, 8'h02});
        @(posedge clk);
        #1;
        if (!result_valid || !busy) $fatal(1, "result should be pending after execution");
        if (result !== 4) $fatal(1, "expected result 4, got %0d", result);

        // Fill the four-entry command queue while the first result is stalled.
        submit_command(32'h0000_0001, 32'h0000_0002);
        submit_command(32'h0000_0001, 32'h0000_0003);
        submit_command(32'h0000_0001, 32'h0000_0004);
        submit_command(32'h0000_0001, 32'h0000_0005);
        @(negedge clk);
        if (cmd_ready) $fatal(1, "processor must apply backpressure when queue is full");
        if (result !== 4) $fatal(1, "stalled result changed");

        // Release the consumer and verify FIFO ordering across the queued results.
        result_ready = 1'b1;
        @(posedge clk);
        #1;
        if (!result_valid || result !== 2) $fatal(1, "queued result 2 was not delivered");
        @(posedge clk);
        #1;
        if (!result_valid || result !== 3) $fatal(1, "queued result 3 was not delivered");
        @(posedge clk);
        #1;
        if (!result_valid || result !== 4) $fatal(1, "queued result 4 was not delivered");
        @(posedge clk);
        #1;
        if (!result_valid || result !== 5) $fatal(1, "queued result 5 was not delivered");
        @(posedge clk);
        #1;
        if (result_valid || busy) $fatal(1, "all queued results should be consumed");
        if (!done || !irq) $fatal(1, "completion and interrupt should be asserted");
        csr_read_word(4'h4, 32'h0000_0006);

        // CONTROL bit 2 clears sticky completion; enable and IRQ remain set.
        csr_write_word(4'h0, 32'h0000_0007);
        if (done || irq) $fatal(1, "completion clear did not deassert done/irq");

        // Disabling the processor blocks new commands.
        csr_write_word(4'h0, 32'h0000_0000);
        @(negedge clk);
        if (cmd_ready) $fatal(1, "disabled processor must not accept commands");

        $display("ii_inference_processor_tb: PASS");
        $finish;
    end
endmodule
