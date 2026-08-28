// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

// Simple 32-bit memory-mapped adapter for the IAIC v1.0 processor slice.
//
// This is intentionally bus-protocol agnostic: a request is presented with
// bus_valid and is accepted when bus_ready is high. A registered response is
// returned through bus_rsp_valid one cycle later. The adapter is suitable for
// a small FPGA shell or a future RISC-V load/store bridge.
module ii_inference_processor_mmio #(
    parameter int LANES = 16,
    parameter int ACC_WIDTH = 32,
    parameter int CMD_QUEUE_DEPTH = 4
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         bus_valid,
    input  logic                         bus_write,
    input  logic [7:0]                   bus_addr,
    input  logic [31:0]                  bus_wdata,
    output logic                         bus_ready,
    output logic                         bus_rsp_valid,
    output logic [31:0]                  bus_rdata,
    output logic                         irq
);

    localparam int VECTOR_WORDS = (LANES + 3) / 4;
    localparam logic [7:0] CONTROL_ADDR = 8'h00;
    localparam logic [7:0] STATUS_ADDR = 8'h04;
    localparam logic [7:0] RESULT_ADDR = 8'h08;
    localparam logic [7:0] VERSION_ADDR = 8'h0c;
    localparam logic [7:0] ACTIVATION_BASE = 8'h10;
    localparam logic [7:0] WEIGHT_BASE = 8'h20;
    localparam logic [7:0] COMMAND_ADDR = 8'h30;

    logic [31:0] activation_words [0:VECTOR_WORDS-1];
    logic [31:0] weight_words [0:VECTOR_WORDS-1];
    logic [LANES*8-1:0] packed_activations;
    logic [LANES*8-1:0] packed_weights;
    logic [31:0] local_rdata;
    logic [31:0] local_rdata_reg;
    logic local_rsp_valid;
    logic local_request;
    logic csr_request;
    logic command_request;
    logic command_ready;
    logic command_valid;
    logic result_ready;
    logic processor_csr_rsp_valid;
    logic [31:0] processor_csr_rdata;
    logic processor_csr_ready;
    logic processor_busy;
    logic processor_done;
    integer word;

    always_comb begin
        packed_activations = '0;
        packed_weights = '0;
        for (word = 0; word < VECTOR_WORDS; word = word + 1) begin
            packed_activations[word*32 +: 32] = activation_words[word];
            packed_weights[word*32 +: 32] = weight_words[word];
        end
    end

    always_comb begin
        csr_request = bus_valid &&
            ((bus_addr == CONTROL_ADDR) || (bus_addr == STATUS_ADDR) ||
             (bus_addr == RESULT_ADDR) || (bus_addr == VERSION_ADDR));
        command_request = bus_valid && bus_write && (bus_addr == COMMAND_ADDR);
        local_request = bus_valid && !csr_request;
        // A command request must wait for queue space. All other accesses are
        // accepted immediately.
        bus_ready = !command_request || command_ready;
        command_valid = command_request && bus_ready;
        result_ready = bus_valid && !bus_write && (bus_addr == RESULT_ADDR) && bus_ready;
    end

    always_comb begin
        local_rdata = 32'h0000_0000;
        if (!bus_write && (bus_addr >= ACTIVATION_BASE) &&
            (bus_addr < ACTIVATION_BASE + VECTOR_WORDS*4)) begin
            local_rdata = activation_words[(bus_addr - ACTIVATION_BASE) >> 2];
        end else if (!bus_write && (bus_addr >= WEIGHT_BASE) &&
                     (bus_addr < WEIGHT_BASE + VECTOR_WORDS*4)) begin
            local_rdata = weight_words[(bus_addr - WEIGHT_BASE) >> 2];
        end
    end

    // The processor CSR response is already registered internally. The local
    // vector-register response is registered below; muxing them here keeps
    // both response types visible in the same cycle as bus_rsp_valid.
    always_comb begin
        bus_rsp_valid = processor_csr_rsp_valid || local_rsp_valid;
        if (processor_csr_rsp_valid) begin
            bus_rdata = processor_csr_rdata;
        end else begin
            bus_rdata = local_rdata_reg;
        end
    end

    ii_inference_processor #(
        .LANES(LANES),
        .ACC_WIDTH(ACC_WIDTH),
        .CMD_QUEUE_DEPTH(CMD_QUEUE_DEPTH)
    ) processor (
        .clk             (clk),
        .rst_n           (rst_n),
        .csr_valid       (csr_request && bus_ready),
        .csr_write       (bus_write),
        .csr_addr        (bus_addr[3:0]),
        .csr_wdata       (bus_wdata),
        .csr_ready       (processor_csr_ready),
        .csr_rsp_valid   (processor_csr_rsp_valid),
        .csr_rdata       (processor_csr_rdata),
        .cmd_valid       (command_valid),
        .cmd_ready       (command_ready),
        .cmd_activations (packed_activations),
        .cmd_weights     (packed_weights),
        .result_valid    (),
        .result_ready    (result_ready),
        .result          (),
        .busy            (processor_busy),
        .done            (processor_done),
        .irq             (irq)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            local_rsp_valid <= 1'b0;
            local_rdata_reg <= 32'h0000_0000;
            for (word = 0; word < VECTOR_WORDS; word = word + 1) begin
                activation_words[word] <= 32'h0000_0000;
                weight_words[word] <= 32'h0000_0000;
            end
        end else begin
            local_rsp_valid <= local_request && bus_ready;
            if (local_request && bus_ready && !bus_write) begin
                local_rdata_reg <= local_rdata;
            end

            if (bus_valid && bus_ready && bus_write &&
                (bus_addr >= ACTIVATION_BASE) &&
                (bus_addr < ACTIVATION_BASE + VECTOR_WORDS*4)) begin
                activation_words[(bus_addr - ACTIVATION_BASE) >> 2] <= bus_wdata;
            end
            if (bus_valid && bus_ready && bus_write &&
                (bus_addr >= WEIGHT_BASE) &&
                (bus_addr < WEIGHT_BASE + VECTOR_WORDS*4)) begin
                weight_words[(bus_addr - WEIGHT_BASE) >> 2] <= bus_wdata;
            end

        end
    end

endmodule
