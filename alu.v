
// ====================
// ALU MODULE
// ====================
module alu (
    input wire [31:0] operand_a,
    input wire [31:0] operand_b,
    input wire [4:0] alu_op,
    input wire carry_in,
    output reg [31:0] result,
    output reg carry_out,
    output reg zero_flag,
    output reg negative_flag,
    output reg overflow_flag
);

reg [32:0] temp_result;

always @(*) begin
    carry_out = 1'b0;
    overflow_flag = 1'b0;
    temp_result = 33'b0;
    
    case (alu_op)
        `OP_MOV: begin
            result = operand_b;
        end
        `OP_MVN: begin
            result = ~operand_b;
        end
        `OP_ADD: begin
            temp_result = operand_a + operand_b;
            result = temp_result[31:0];
            carry_out = temp_result[32];
            overflow_flag = (operand_a[31] == operand_b[31]) && (result[31] != operand_a[31]);
        end
        `OP_ADC: begin
            temp_result = operand_a + operand_b + carry_in;
            result = temp_result[31:0];
            carry_out = temp_result[32];
            overflow_flag = (operand_a[31] == operand_b[31]) && (result[31] != operand_a[31]);
        end
        `OP_SUB: begin
            temp_result = operand_a - operand_b;
            result = temp_result[31:0];
            carry_out = !temp_result[32];
            overflow_flag = (operand_a[31] != operand_b[31]) && (result[31] != operand_a[31]);
        end
        `OP_SBC: begin
            temp_result = operand_a - operand_b - !carry_in;
            result = temp_result[31:0];
            carry_out = !temp_result[32];
            overflow_flag = (operand_a[31] != operand_b[31]) && (result[31] != operand_a[31]);
        end
        `OP_RSB: begin
            temp_result = operand_b - operand_a;
            result = temp_result[31:0];
            carry_out = !temp_result[32];
            overflow_flag = (operand_b[31] != operand_a[31]) && (result[31] != operand_b[31]);
        end
        `OP_MUL: begin
            result = operand_a * operand_b;
        end
        `OP_NEG: begin
            result = -operand_a;
        end
        `OP_AND: begin
            result = operand_a & operand_b;
        end
        `OP_ORR: begin
            result = operand_a | operand_b;
        end
        `OP_EOR: begin
            result = operand_a ^ operand_b;
        end
        `OP_BIC: begin
            result = operand_a & (~operand_b);
        end
        `OP_TST: begin
            result = operand_a & operand_b;
        end
        `OP_CMP: begin
            temp_result = operand_a - operand_b;
            result = temp_result[31:0];
            carry_out = !temp_result[32];
            overflow_flag = (operand_a[31] != operand_b[31]) && (result[31] != operand_a[31]);
        end
        `OP_CMN: begin
            temp_result = operand_a + operand_b;
            result = temp_result[31:0];
            carry_out = temp_result[32];
            overflow_flag = (operand_a[31] == operand_b[31]) && (result[31] != operand_a[31]);
        end
        default: begin
            result = 32'b0;
        end
    endcase
    
    zero_flag = (result == 32'b0);
    negative_flag = result[31];
end

endmodule

