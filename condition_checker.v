
// ====================
// CONDITION CHECKER MODULE
// ====================
module condition_checker (
    input wire [3:0] condition,
    input wire zero_flag,
    input wire carry_flag,
    input wire negative_flag,
    input wire overflow_flag,
    output reg condition_met
);

always @(*) begin
    case (condition)
        4'b0000: condition_met = zero_flag;           // EQ
        4'b0001: condition_met = ~zero_flag;          // NE
        4'b0010: condition_met = carry_flag;          // CS/HS
        4'b0011: condition_met = ~carry_flag;         // CC/LO
        4'b0100: condition_met = negative_flag;       // MI
        4'b0101: condition_met = ~negative_flag;      // PL
        4'b0110: condition_met = overflow_flag;       // VS
        4'b0111: condition_met = ~overflow_flag;      // VC
        4'b1000: condition_met = carry_flag & ~zero_flag; // HI
        4'b1001: condition_met = ~carry_flag | zero_flag; // LS
        4'b1010: condition_met = negative_flag == overflow_flag; // GE
        4'b1011: condition_met = negative_flag != overflow_flag; // LT
        4'b1100: condition_met = ~zero_flag & (negative_flag == overflow_flag); // GT
        4'b1101: condition_met = zero_flag | (negative_flag != overflow_flag);  // LE
        4'b1110: condition_met = 1'b1;                // AL (always)
        4'b1111: condition_met = 1'b0;                // NV (never)
    endcase
end

endmodule
