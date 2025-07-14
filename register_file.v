// ====================
// REGISTER FILE MODULE
// ====================
module register_file (
    input wire clk,
    input wire rst,
    input wire [3:0] read_addr1,
    input wire [3:0] read_addr2,
    input wire [3:0] write_addr,
    input wire [31:0] write_data,
    input wire write_enable,
    output reg [31:0] read_data1,
    output reg [31:0] read_data2
);

reg [31:0] registers [0:15];
integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1) begin
            registers[i] <= 32'b0;
        end
        registers[13] <= 32'h00001000; // SP
        registers[14] <= 32'h00000000; // LR
        registers[15] <= 32'h00000000; // PC
    end else if (write_enable && write_addr != 4'b1111) begin
        registers[write_addr] <= write_data;
    end
end

// Combinational read
always @(*) begin
    read_data1 = (read_addr1 == 4'b1111) ? 32'b0 : registers[read_addr1];
    read_data2 = (read_addr2 == 4'b1111) ? 32'b0 : registers[read_addr2];
end

endmodule
