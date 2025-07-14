// ====================
// BRANCH CALCULATOR MODULE
// ====================
module branch_calculator (
    input wire [31:0] pc,
    input wire [23:0] branch_offset,
    input wire [4:0] opcode,
    output reg [31:0] branch_target
);

reg [31:0] sign_extended_offset;

always @(*) begin
    // Sign extend the 24-bit offset to 32 bits
    sign_extended_offset = {{6{branch_offset[23]}}, branch_offset, 2'b00};
    
    case (opcode)
        `OP_B, `OP_BL, `OP_BEQ, `OP_BNE: begin
            branch_target = pc + 8 + sign_extended_offset; // PC+8 due to ARM pipeline
        end
        default: begin
            branch_target = pc + 4;
        end
    endcase
end

endmodule

