
// ====================
// PROGRAM COUNTER MODULE
// ====================
module program_counter (
    input wire clk,
    input wire rst,
    input wire stall,
    input wire branch_taken,
    input wire [31:0] branch_target,
    output reg [31:0] pc
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 32'h00000000;
    end else if (!stall) begin
        if (branch_taken) begin
            pc <= branch_target;
        end else begin
            pc <= pc + 4;
        end
    end
end

endmodule
