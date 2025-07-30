
// ====================
// PROGRAM COUNTER MODULE
// ====================
module pc_unit (
    input        clk,
    input        rst_n,
    input        branch_taken_in,
    input [31:0] branch_target_addr_in,
    input        stall_in,
    output [31:0] pc_out
);
    reg [31:0] pc_reg;
    assign pc_out = pc_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 32'h00000000;
        end else if (stall_in) begin
            pc_reg <= pc_reg; // Freeze the PC
        end else if (branch_taken_in) begin
            pc_reg <= branch_target_addr_in; // Jump to new address
        end else begin
            pc_reg <= pc_reg + 2; // Increment normally
        end
    end
endmodule
