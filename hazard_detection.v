
// ====================
// HAZARD DETECTION MODULE
// ====================
module hazard_detection (
    input wire [3:0] if_id_rs1,
    input wire [3:0] if_id_rs2,
    input wire [3:0] id_ex_rd,
    input wire id_ex_mem_read,
    input wire branch_taken,
    output reg stall,
    output reg flush
);

always @(*) begin
    stall = 1'b0;
    flush = 1'b0;
    
    // Load-use hazard detection
    if (id_ex_mem_read && 
        ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
        stall = 1'b1;
    end
    
    // Branch hazard
    if (branch_taken) begin
        flush = 1'b1;
    end
end

endmodule
