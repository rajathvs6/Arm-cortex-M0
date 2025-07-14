// ====================
// MAIN PROCESSOR MODULE
// ====================
module arm_processor (
    input wire clk,
    input wire rst,
    output wire [31:0] pc_out,
    output wire [31:0] instruction_out,
    output wire [31:0] alu_result_out,
    output wire [3:0] flags_out
);

// Internal signals
wire [31:0] pc, next_pc, branch_target;
wire [31:0] instruction;
wire branch_taken, stall, flush;

// Decoded instruction signals
wire [4:0] opcode;
wire [3:0] rd, rs1, rs2;
wire [11:0] immediate;
wire [23:0] branch_offset;
wire [4:0] shift_amount;
wire [1:0] shift_type;
wire immediate_flag, write_back_flag;
wire [3:0] condition;
wire reg_write_en, mem_read_en, mem_write_en, mem_byte_en;
wire branch_en, link_en, flags_update_en;

// Pipeline register signals
wire [31:0] id_instruction, id_pc;
wire [4:0] ex_opcode;
wire [3:0] ex_rd, ex_rs1, ex_rs2;
wire [11:0] ex_immediate;
wire [23:0] ex_branch_offset;
wire [4:0] ex_shift_amount;
wire [1:0] ex_shift_type;
wire ex_immediate_flag, ex_reg_write_en, ex_mem_read_en, ex_mem_write_en, ex_mem_byte_en;
wire ex_branch_en, ex_flags_update_en;
wire [3:0] ex_condition;
wire [31:0] ex_reg_data1, ex_reg_data2, ex_pc;

// Register file signals
wire [31:0] reg_data1, reg_data2, reg_write_data;
wire reg_write_enable;

// ALU signals
wire [31:0] alu_operand_a, alu_operand_b, alu_result;
wire alu_carry_out, alu_zero, alu_negative, alu_overflow;

// Shifter signals
wire [31:0] shifted_data;
wire shift_carry_out;

// Status register signals
wire status_zero, status_carry, status_negative, status_overflow;

// Memory signals
wire [31:0] mem_read_data;

// Forwarding signals
wire [1:0] forward_a, forward_b;
wire [31:0] forwarded_data_a, forwarded_data_b;

// Condition checker signals
wire condition_met;

// Immediate extender signals
wire [31:0] extended_immediate;

// Output assignments
assign pc_out = pc;
assign instruction_out = instruction;
assign alu_result_out = alu_result;
assign flags_out = {status_negative, status_zero, status_carry, status_overflow};

// Instantiate modules
program_counter pc_module (
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .branch_taken(branch_taken),
    .branch_target(branch_target),
    .pc(pc)
);

instruction_memory imem (
    .clk(clk),
    .rst(rst),
    .address(pc),
    .instruction(instruction)
);

instruction_decoder decoder (
    .instruction(id_instruction),
    .opcode(opcode),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .immediate(immediate),
    .branch_offset(branch_offset),
    .shift_amount(shift_amount),
    .shift_type(shift_type),
    .immediate_flag(immediate_flag),
    .write_back_flag(write_back_flag),
    .condition(condition),
    .reg_write_en(reg_write_en),
    .mem_read_en(mem_read_en),
    .mem_write_en(mem_write_en),
    .mem_byte_en(mem_byte_en),
    .branch_en(branch_en),
    .link_en(link_en),
    .flags_update_en(flags_update_en)
);

pipeline_registers pipeline_regs (
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .flush(flush),
    
    // IF/ID inputs
    .if_instruction(instruction),
    .if_pc(pc),
    .id_instruction(id_instruction),
    .id_pc(id_pc),
    
    // ID/EX inputs
    .id_opcode(opcode),
    .id_rd(rd),
    .id_rs1(rs1),
    .id_rs2(rs2),
    .id_immediate(immediate),
    .id_branch_offset(branch_offset),
    .id_shift_amount(shift_amount),
    .id_shift_type(shift_type),
    .id_immediate_flag(immediate_flag),
    .id_reg_write_en(reg_write_en),
    .id_mem_read_en(mem_read_en),
    .id_mem_write_en(mem_write_en),
    .id_mem_byte_en(mem_byte_en),
    .id_branch_en(branch_en),
    .id_flags_update_en(flags_update_en),
    .id_condition(condition),
    .id_reg_data1(reg_data1),
    .id_reg_data2(reg_data2),
    
    // ID/EX outputs
    .ex_opcode(ex_opcode),
    .ex_rd(ex_rd),
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),
    .ex_immediate(ex_immediate),
    .ex_branch_offset(ex_branch_offset),
    .ex_shift_amount(ex_shift_amount),
    .ex_shift_type(ex_shift_type),
    .ex_immediate_flag(ex_immediate_flag),
    .ex_reg_write_en(ex_reg_write_en),
    .ex_mem_read_en(ex_mem_read_en),
    .ex_mem_write_en(ex_mem_write_en),
    .ex_mem_byte_en(ex_mem_byte_en),
    .ex_branch_en(ex_branch_en),
    .ex_flags_update_en(ex_flags_update_en),
    .ex_condition(ex_condition),
    .ex_reg_data1(ex_reg_data1),
    .ex_reg_data2(ex_reg_data2),
    .ex_pc(ex_pc)
);

register_file reg_file (
    .clk(clk),
    .rst(rst),
    .read_addr1(rs1),
    .read_addr2(rs2),
    .write_addr(ex_rd),
    .write_data(reg_write_data),
    .write_enable(ex_reg_write_en && condition_met),
    .read_data1(reg_data1),
    .read_data2(reg_data2)
);

hazard_detection hazard_unit (
    .if_id_rs1(rs1),
    .if_id_rs2(rs2),
    .id_ex_rd(ex_rd),
    .id_ex_mem_read(ex_mem_read_en),
    .branch_taken(branch_taken),
    .stall(stall),
    .flush(flush)
);

forwarding_unit forward_unit (
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),
    .mem_rd(ex_rd),
    .wb_rd(4'b0),
    .mem_reg_write(ex_reg_write_en),
    .wb_reg_write(1'b0),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

// Forwarding multiplexers
assign forwarded_data_a = (forward_a == 2'b10) ? alu_result :
                         (forward_a == 2'b01) ? reg_write_data : ex_reg_data1;
assign forwarded_data_b = (forward_b == 2'b10) ? alu_result :
                         (forward_b == 2'b01) ? reg_write_data : ex_reg_data2;

immediate_extender imm_ext (
    .immediate(ex_immediate),
    .rotate(ex_immediate[11:8]),
    .extended_immediate(extended_immediate)
);

shifter shift_unit (
    .data_in(forwarded_data_b),
    .shift_amount(ex_shift_amount),
    .shift_type(ex_shift_type),
    .carry_in(status_carry),
    .data_out(shifted_data),
    .carry_out(shift_carry_out)
);

// ALU operand selection
assign alu_operand_a = forwarded_data_a;
assign alu_operand_b = ex_immediate_flag ? extended_immediate : shifted_data;

alu alu_unit (
    .operand_a(alu_operand_a),
    .operand_b(alu_operand_b),
    .alu_op(ex_opcode),
    .carry_in(status_carry),
    .result(alu_result),
    .carry_out(alu_carry_out),
    .zero_flag(alu_zero),
    .negative_flag(alu_negative),
    .overflow_flag(alu_overflow)
);

condition_checker cond_check (
    .condition(ex_condition),
    .zero_flag(status_zero),
    .carry_flag(status_carry),
    .negative_flag(status_negative),
    .overflow_flag(status_overflow),
    .condition_met(condition_met)
);

branch_calculator branch_calc (
    .pc(ex_pc),
    .branch_offset(ex_branch_offset),
    .opcode(ex_opcode),
    .branch_target(branch_target)
);

data_memory dmem (
    .clk(clk),
    .rst(rst),
    .address(alu_result),
    .write_data(forwarded_data_b),
    .write_enable(ex_mem_write_en && condition_met),
    .read_enable(ex_mem_read_en && condition_met),
    .byte_enable(ex_mem_byte_en),
    .read_data(mem_read_data)
);

status_register status_reg (
    .clk(clk),
    .rst(rst),
    .update_flags(ex_flags_update_en && condition_met),
    .zero_flag(alu_zero),
    .carry_flag(alu_carry_out),
    .negative_flag(alu_negative),
    .overflow_flag(alu_overflow),
    .status_zero(status_zero),
    .status_carry(status_carry),
    .status_negative(status_negative),
    .status_overflow(status_overflow)
);

// Write-back data selection
assign reg_write_data = ex_mem_read_en ? mem_read_data : alu_result;

// Branch decision
assign branch_taken = ex_branch_en && condition_met;

endmodule
