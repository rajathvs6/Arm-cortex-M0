// ====================
// STATUS REGISTER MODULE
// ====================
module status_register (
    input wire clk,
    input wire rst,
    input wire update_flags,
    input wire zero_flag,
    input wire carry_flag,
    input wire negative_flag,
    input wire overflow_flag,
    output reg status_zero,
    output reg status_carry,
    output reg status_negative,
    output reg status_overflow
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        status_zero <= 1'b0;
        status_carry <= 1'b0;
        status_negative <= 1'b0;
        status_overflow <= 1'b0;
    end else if (update_flags) begin
        status_zero <= zero_flag;
        status_carry <= carry_flag;
        status_negative <= negative_flag;
        status_overflow <= overflow_flag;
    end
end

endmodule
