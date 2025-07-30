
// ====================
// DATA MEMORY MODULE (FIXED NAME)
// ====================
module data_memory (
    input         clk,
    input         mem_read_en,
    input         mem_write_en,
    input  [31:0] addr_in,
    input  [31:0] write_data_in,
    output [31:0] read_data_out
);
    reg [31:0] memory [0:255];

    always @(posedge clk) begin
        if (mem_write_en) begin
            memory[addr_in >> 2] <= write_data_in;
        end
    end

    assign read_data_out = mem_read_en ? memory[addr_in >> 2] : 32'b0;
endmodule

