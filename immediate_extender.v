
// ====================
// IMMEDIATE EXTENDER MODULE
// ====================
module immediate_extender (
    input wire [11:0] immediate,
    input wire [4:0] rotate,
    output reg [31:0] extended_immediate
);

reg [31:0] temp_immediate;

always @(*) begin
    temp_immediate = {24'b0, immediate[7:0]};
    extended_immediate = (temp_immediate >> (rotate * 2)) | (temp_immediate << (32 - (rotate * 2)));
end

endmodule

