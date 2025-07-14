// ====================
// INSTRUCTION DECODER MODULE
// ====================
module instruction_decoder (
    input wire [31:0] instruction,
    output reg [4:0] opcode,
    output reg [3:0] rd, rs1, rs2,
    output reg [11:0] immediate,
    output reg [23:0] branch_offset,
    output reg [4:0] shift_amount,
    output reg [1:0] shift_type,
    output reg immediate_flag,
    output reg write_back_flag,
    output reg [3:0] condition,
    output reg reg_write_en,
    output reg mem_read_en,
    output reg mem_write_en,
    output reg mem_byte_en,
    output reg branch_en,
    output reg link_en,
    output reg flags_update_en
);

always @(*) begin
    // Default values
    opcode = 5'b11111;
    rd = 4'b0000;
    rs1 = 4'b0000;
    rs2 = 4'b0000;
    immediate = 12'b0;
    branch_offset = 24'b0;
    shift_amount = 5'b0;
    shift_type = 2'b0;
    immediate_flag = 1'b0;
    write_back_flag = 1'b0;
    condition = 4'b1110; // Always
    reg_write_en = 1'b0;
    mem_read_en = 1'b0;
    mem_write_en = 1'b0;
    mem_byte_en = 1'b0;
    branch_en = 1'b0;
    link_en = 1'b0;
    flags_update_en = 1'b0;
    
    condition = instruction[31:28];
    
    case (instruction[27:25])
        3'b000: begin // Data processing
            opcode = {1'b0, instruction[24:21]};
            rd = instruction[15:12];
            rs1 = instruction[19:16];
            immediate_flag = instruction[25];
            flags_update_en = instruction[20];
            
            if (instruction[25]) begin // Immediate
                immediate = instruction[11:0];
            end else begin // Register
                rs2 = instruction[3:0];
                shift_amount = instruction[11:7];
                shift_type = instruction[6:5];
            end
            
            case (instruction[24:21])
                4'b0000: begin // AND
                    opcode = `OP_AND;
                    reg_write_en = 1'b1;
                end
                4'b0001: begin // EOR
                    opcode = `OP_EOR;
                    reg_write_en = 1'b1;
                end
                4'b0010: begin // SUB
                    opcode = `OP_SUB;
                    reg_write_en = 1'b1;
                end
                4'b0011: begin // RSB
                    opcode = `OP_RSB;
                    reg_write_en = 1'b1;
                end
                4'b0100: begin // ADD
                    opcode = `OP_ADD;
                    reg_write_en = 1'b1;
                end
                4'b0101: begin // ADC
                    opcode = `OP_ADC;
                    reg_write_en = 1'b1;
                end
                4'b0110: begin // SBC
                    opcode = `OP_SBC;
                    reg_write_en = 1'b1;
                end
                4'b1000: begin // TST
                    opcode = `OP_TST;
                    flags_update_en = 1'b1;
                end
                4'b1001: begin // TEQ (not implemented, using EOR)
                    opcode = `OP_EOR;
                    flags_update_en = 1'b1;
                end
                4'b1010: begin // CMP
                    opcode = `OP_CMP;
                    flags_update_en = 1'b1;
                end
                4'b1011: begin // CMN
                    opcode = `OP_CMN;
                    flags_update_en = 1'b1;
                end
                4'b1100: begin // ORR
                    opcode = `OP_ORR;
                    reg_write_en = 1'b1;
                end
                4'b1101: begin // MOV
                    opcode = `OP_MOV;
                    reg_write_en = 1'b1;
                end
                4'b1110: begin // BIC
                    opcode = `OP_BIC;
                    reg_write_en = 1'b1;
                end
                4'b1111: begin // MVN
                    opcode = `OP_MVN;
                    reg_write_en = 1'b1;
                end
            endcase
        end
        
        3'b001: begin // Data processing immediate
            opcode = {1'b0, instruction[24:21]};
            rd = instruction[15:12];
            rs1 = instruction[19:16];
            immediate = instruction[11:0];
            immediate_flag = 1'b1;
            flags_update_en = instruction[20];
            reg_write_en = 1'b1;
        end
        
        3'b010: begin // Load/Store
            rd = instruction[15:12];
            rs1 = instruction[19:16];
            immediate = instruction[11:0];
            immediate_flag = 1'b1;
            
            if (instruction[20]) begin // Load
                if (instruction[22]) begin // Byte
                    opcode = `OP_LDRB;
                    mem_byte_en = 1'b1;
                end else begin // Word
                    opcode = `OP_LDR;
                end
                mem_read_en = 1'b1;
                reg_write_en = 1'b1;
            end else begin // Store
                if (instruction[22]) begin // Byte
                    opcode = `OP_STRB;
                    mem_byte_en = 1'b1;
                end else begin // Word
                    opcode = `OP_STR;
                end
                mem_write_en = 1'b1;
                rs2 = rd; // Data to store
            end
        end
        
        3'b101: begin // Branch
            branch_offset = instruction[23:0];
            branch_en = 1'b1;
            
            if (instruction[24]) begin // BL
                opcode = `OP_BL;
                link_en = 1'b1;
                reg_write_en = 1'b1;
            end else begin // B
                opcode = `OP_B;
            end
            
            // Handle conditional branches
            case (condition)
                4'b0000: opcode = `OP_BEQ;
                4'b0001: opcode = `OP_BNE;
                default: opcode = `OP_B;
            endcase
        end
        
        default: begin
            opcode = 5'b11111; // Invalid
        end
    endcase
end

endmodule
