// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 India AI Inference Chip v1.0 contributors

// IAIC v1.0 inference processor slice.
//
// This block is the first software-visible execution unit in the project. It
// accepts one packed INT8 activation/weight command, computes a signed dot
// product, and exposes the result through a ready/valid stream. A small CSR
// interface controls execution and reports completion for a future RISC-V
// host, DMA engine, or FPGA shell.
module ii_inference_processor #(
    parameter int LANES = 16,
    parameter int ACC_WIDTH = 32,
    parameter int CMD_QUEUE_DEPTH = 4
) (
    input  logic                         clk,
    input  logic                         rst_n,

    // Single-cycle CSR request, with a registered response one cycle later.
    input  logic                         csr_valid,
    input  logic                         csr_write,
    input  logic [3:0]                   csr_addr,
    input  logic [31:0]                  csr_wdata,
    output logic                         csr_ready,
    output logic                         csr_rsp_valid,
    output logic [31:0]                  csr_rdata,

    // One packed INT8 command per accepted ready/valid transfer.
    input  logic                         cmd_valid,
    output logic                         cmd_ready,
    input  logic [LANES*8-1:0]           cmd_activations,
    input  logic [LANES*8-1:0]           cmd_weights,

    // Result remains stable while result_valid && !result_ready.
    output logic                         result_valid,
    input  logic                         result_ready,
    output logic signed [ACC_WIDTH-1:0]  result,

    output logic                         busy,
    output logic                         done,
    output logic                         irq
);

    localparam logic [3:0] CSR_CONTROL = 4'h0;
    localparam logic [3:0] CSR_STATUS  = 4'h4;
    localparam logic [3:0] CSR_RESULT  = 4'h8;
    localparam logic [3:0] CSR_VERSION = 4'hc;

    logic enable;
    logic irq_enable;
    logic core_ready_in;
    logic core_valid_out;
    logic signed [ACC_WIDTH-1:0] core_result;
    logic [31:0] csr_read_data;
    localparam int PTR_WIDTH = (CMD_QUEUE_DEPTH <= 1) ? 1 : $clog2(CMD_QUEUE_DEPTH);
    localparam int COUNT_WIDTH = $clog2(CMD_QUEUE_DEPTH + 1);
    logic [LANES*8-1:0] activation_fifo [0:CMD_QUEUE_DEPTH-1];
    logic [LANES*8-1:0] weight_fifo [0:CMD_QUEUE_DEPTH-1];
    logic [PTR_WIDTH-1:0] write_ptr;
    logic [PTR_WIDTH-1:0] read_ptr;
    logic [COUNT_WIDTH-1:0] queue_count;
    logic compute_valid;
    logic enqueue;
    logic dequeue;

    function automatic [PTR_WIDTH-1:0] next_ptr(input logic [PTR_WIDTH-1:0] ptr);
        begin
            if (ptr == CMD_QUEUE_DEPTH - 1) begin
                next_ptr = '0;
            end else begin
                next_ptr = ptr + 1'b1;
            end
        end
    endfunction

    // The current processor is always available for CSR accesses. The
    // command path is gated by CONTROL.enable; pending results remain visible
    // and consumable even if software disables new command acceptance.
    assign csr_ready = 1'b1;
    assign cmd_ready = enable && (queue_count < CMD_QUEUE_DEPTH);
    assign enqueue = cmd_valid && cmd_ready;
    assign compute_valid = (queue_count != 0);
    assign dequeue = compute_valid && core_ready_in;
    assign result_valid = core_valid_out;
    assign result = core_result;
    assign busy = (queue_count != 0) || core_valid_out;
    assign irq = done && irq_enable;

    ii_dot_product_stream #(
        .LANES(LANES),
        .ACC_WIDTH(ACC_WIDTH)
    ) compute_unit (
        .clk        (clk),
        .rst_n      (rst_n),
        .valid_in   (compute_valid),
        .ready_in   (core_ready_in),
        .activations(activation_fifo[read_ptr]),
        .weights    (weight_fifo[read_ptr]),
        .valid_out  (core_valid_out),
        .ready_out  (result_ready),
        .result     (core_result)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr  <= '0;
            read_ptr   <= '0;
            queue_count <= '0;
        end else begin
            if (enqueue) begin
                activation_fifo[write_ptr] <= cmd_activations;
                weight_fifo[write_ptr] <= cmd_weights;
                write_ptr <= next_ptr(write_ptr);
            end

            if (dequeue) begin
                read_ptr <= next_ptr(read_ptr);
            end

            case ({enqueue, dequeue})
                2'b10: queue_count <= queue_count + 1'b1;
                2'b01: queue_count <= queue_count - 1'b1;
                default: queue_count <= queue_count;
            endcase
        end
    end

    always_comb begin
        csr_read_data = 32'h0000_0000;
        case (csr_addr)
            CSR_CONTROL: begin
                csr_read_data[0] = enable;
                csr_read_data[1] = irq_enable;
            end
            CSR_STATUS: begin
                csr_read_data[0] = busy;
                csr_read_data[1] = done;
                csr_read_data[2] = cmd_ready;
                csr_read_data[3] = result_valid;
            end
            CSR_RESULT: begin
                // The CSR is fixed at 32 bits. Wider accumulators expose the
                // low word; narrower accumulators are sign-extended.
                if (ACC_WIDTH >= 32) begin
                    csr_read_data = core_result[31:0];
                end else begin
                    csr_read_data = {{(32-ACC_WIDTH){core_result[ACC_WIDTH-1]}}, core_result};
                end
            end
            CSR_VERSION: begin
                csr_read_data = 32'h0001_0000;
            end
            default: begin
                csr_read_data = 32'h0000_0000;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            enable        <= 1'b0;
            irq_enable    <= 1'b0;
            csr_rsp_valid <= 1'b0;
            csr_rdata     <= 32'h0000_0000;
            done          <= 1'b0;
        end else begin
            // CSR responses are synchronous and always complete because
            // csr_ready is permanently asserted.
            csr_rsp_valid <= csr_valid;
            if (csr_valid && !csr_write) begin
                csr_rdata <= csr_read_data;
            end else begin
                csr_rdata <= 32'h0000_0000;
            end

            if (csr_valid && csr_write && (csr_addr == CSR_CONTROL)) begin
                enable     <= csr_wdata[0];
                irq_enable <= csr_wdata[1];
                if (csr_wdata[2]) begin
                    done <= 1'b0;
                end
            end

            // A completion occurring in the same cycle as a clear wins, so
            // software cannot accidentally lose a newly completed command.
            if (core_valid_out && result_ready) begin
                done <= 1'b1;
            end
        end
    end

endmodule
