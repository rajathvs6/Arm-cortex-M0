// ====================
// FORWARDING UNIT MODULE
// ====================
module forwarding_unit (
    input wire [3:0] ex_rs1,
    input wire [3:0] ex_rs2,
    input wire [3:0] mem_rd,
    input wire [3:0] wb_rd,
    input wire mem_reg_write,
    input wire wb_reg_write,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

always @(*) begin
    forward_a = 2'b00;
    forward_b = 2'b00;
    
    // EX hazard
    if (mem_reg_write && (mem_rd != 4'b0000) && (mem_rd == ex_rs1)) begin
        forward_a = 2'b10;
    end
    if (mem_reg_write && (mem_rd != 4'b0000) && (mem_rd == ex_rs2)) begin
        forward_b = 2'b10;
    end
    
    // MEM hazard
    if (wb_reg_write && (wb_rd != 4'b0000) && 
        !(mem_reg_write && (mem_rd != 4'b0000) && (mem_rd == ex_rs1)) &&
        (wb_rd == ex_rs1)) begin
        forward_a = 2'b01;
    end
    if (wb_reg_write && (wb_rd != 4'b0000) && 
        !(mem_reg_write && (mem_rd != 4'b0000) && (mem_rd == ex_rs2)) &&
        (wb_rd == ex_rs2)) begin
        forward_b = 2'b01;
    end
end

endmodule
