
// ====================
// PIPELINE REGISTERS MODULE
// ====================
module pipeline_registers (
    input wire clk,
    input wire rst,
    input wire stall,
    input wire flush,
    
    // IF/ID Pipeline Register
    input wire [31:0] if_instruction,
    input wire [31:0] if_pc,
    output reg [31:0] id_instruction,
    output reg [31:0] id_pc,
    
    // ID/EX Pipeline Register
    input wire [4:0] id_opcode,
    input wire [3:0] id_rd, id_rs1, id_rs2,
    input wire [11:0] id_immediate,
    input wire [23:0] id_branch_offset,
    input wire [4:0] id_shift_amount,
    input wire [1:0] id_shift_type,
    input wire id_immediate_flag,
    input wire id_reg_write_en,
    input wire id_mem_read_en,
    input wire id_mem_write_en,
    input wire id_mem_byte_en,
    input wire id_branch_en,
    input wire id_flags_update_en,
    input wire [3:0] id_condition,
    input wire [31:0] id_reg_data1,
    input wire [31:0] id_reg_data2,
    
    output reg [4:0] ex_opcode,
    output reg [3:0] ex_rd, ex_rs1, ex_rs2,
    output reg [11:0] ex_immediate,
    output reg [23:0] ex_branch_offset,
    output reg [4:0] ex_shift_amount,
    output reg [1:0] ex_shift_type,
    output reg ex_immediate_flag,
    output reg ex_reg_write_en,
    output reg ex_mem_read_en,
    output reg ex_mem_write_en,
    output reg ex_mem_byte_en,
    output reg ex_branch_en,
    output reg ex_flags_update_en,
    output reg [3:0] ex_condition,
    output reg [31:0] ex_reg_data1,
    output reg [31:0] ex_reg_data2,
    output reg [31:0] ex_pc
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // IF/ID Reset
        id_instruction <= 32'b0;
        id_pc <= 32'b0;
        
        // ID/EX Reset
        ex_opcode <= 5'b0;
        ex_rd <= 4'b0;
        ex_rs1 <= 4'b0;
        ex_rs2 <= 4'b0;
        ex_immediate <= 12'b0;
       // Continuation from pipeline_registers module
        ex_branch_offset <= 24'b0;
        ex_shift_amount <= 5'b0;
        ex_shift_type <= 2'b0;
        ex_immediate_flag <= 1'b0;
        ex_reg_write_en <= 1'b0;
        ex_mem_read_en <= 1'b0;
        ex_mem_write_en <= 1'b0;
        ex_mem_byte_en <= 1'b0;
        ex_branch_en <= 1'b0;
        ex_flags_update_en <= 1'b0;
        ex_condition <= 4'b0;
        ex_reg_data1 <= 32'b0;
        ex_reg_data2 <= 32'b0;
        ex_pc <= 32'b0;
        
    end else begin
        // IF/ID Pipeline Register
        if (!stall) begin
            if (flush) begin
                id_instruction <= 32'b0;
                id_pc <= 32'b0;
            end else begin
                id_instruction <= if_instruction;
                id_pc <= if_pc;
            end
        end
        
        // ID/EX Pipeline Register
        if (flush) begin
            ex_opcode <= 5'b0;
            ex_rd <= 4'b0;
            ex_rs1 <= 4'b0;
            ex_rs2 <= 4'b0;
            ex_immediate <= 12'b0;
            ex_branch_offset <= 24'b0;
            ex_shift_amount <= 5'b0;
            ex_shift_type <= 2'b0;
            ex_immediate_flag <= 1'b0;
            ex_reg_write_en <= 1'b0;
            ex_mem_read_en <= 1'b0;
            ex_mem_write_en <= 1'b0;
            ex_mem_byte_en <= 1'b0;
            ex_branch_en <= 1'b0;
            ex_flags_update_en <= 1'b0;
            ex_condition <= 4'b0;
            ex_reg_data1 <= 32'b0;
            ex_reg_data2 <= 32'b0;
            ex_pc <= 32'b0;
        end else begin
            ex_opcode <= id_opcode;
            ex_rd <= id_rd;
            ex_rs1 <= id_rs1;
            ex_rs2 <= id_rs2;
            ex_immediate <= id_immediate;
            ex_branch_offset <= id_branch_offset;
            ex_shift_amount <= id_shift_amount;
            ex_shift_type <= id_shift_type;
            ex_immediate_flag <= id_immediate_flag;
            ex_reg_write_en <= id_reg_write_en;
            ex_mem_read_en <= id_mem_read_en;
            ex_mem_write_en <= id_mem_write_en;
            ex_mem_byte_en <= id_mem_byte_en;
            ex_branch_en <= id_branch_en;
            ex_flags_update_en <= id_flags_update_en;
            ex_condition <= id_condition;
            ex_reg_data1 <= id_reg_data1;
            ex_reg_data2 <= id_reg_data2;
            ex_pc <= id_pc;
        end
    end
end

endmodule
