// ====================
// INSTRUCTION MEMORY MODULE
// ====================
module instruction_memory (
    input wire clk,
    input wire rst,
    input wire [31:0] address,
    output reg [31:0] instruction
);

    reg [31:0] imem [0:1023];  // 4 KB instruction memory (1024 words of 32 bits)

    // Initialize memory with test program
    initial begin
        imem[0]  = 32'hE3A01005; // MOV R1, #5
        imem[1]  = 32'hE3A02003; // MOV R2, #3
        imem[2]  = 32'hE0813002; // ADD R3, R1, R2
        imem[3]  = 32'hE0434001; // SUB R4, R3, R1
        imem[4]  = 32'hE0015002; // AND R5, R1, R2
        imem[5]  = 32'hE1816002; // ORR R6, R1, R2
        imem[6]  = 32'hE0217002; // EOR R7, R1, R2
        imem[7]  = 32'hE1530001; // CMP R3, R1
        imem[8]  = 32'hE1510003; // CMP R1, R3
        imem[9]  = 32'hE3A08000; // MOV R8, #0
        imem[10] = 32'hE3580000; // CMP R8, #0
        imem[11] = 32'hE1A09101; // LSL R9, R1, #2
        imem[12] = 32'hE1A0A0A9; // LSR R10, R9, #1
        imem[13] = 32'hE1E0B001; // MVN R11, R1
        imem[14] = 32'hE1C1C002; // BIC R12, R1, R2
        imem[15] = 32'hE5881000; // STR R1, [R8]
        imem[16] = 32'hE598D000; // LDR R13, [R8]
        imem[17] = 32'h0A000001; // BEQ +4
        imem[18] = 32'hE3A0E00A; // MOV R14, #10
        imem[19] = 32'hEAFFFFFE; // B (infinite loop)
        
        // Initialize remaining memory to NOPs
        for (integer i = 20; i < 1024; i = i + 1) begin
            imem[i] = 32'hE1A00000; // NOP
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instruction <= 32'hE1A00000; // NOP (MOV R0, R0)
        end else begin
            instruction <= imem[address[11:2]]; // Word-aligned access
        end
    end

endmodule
