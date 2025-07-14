
// ====================
// DATA MEMORY MODULE (FIXED NAME)
// ====================
module data_memory (
    input wire clk,
    input wire rst,
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire write_enable,
    input wire read_enable,
    input wire byte_enable,
    output reg [31:0] read_data
);

    reg [7:0] dmem [0:4095];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize memory to zero on reset
            for (i = 0; i < 4096; i = i + 1) begin
                dmem[i] <= 8'b0;
            end
            read_data <= 32'b0;
        end else begin
            if (write_enable) begin
                if (byte_enable) begin
                    dmem[address[11:0]] <= write_data[7:0];
                end else begin
                    dmem[address[11:0]] <= write_data[7:0];
                    dmem[address[11:0] + 1] <= write_data[15:8];
                    dmem[address[11:0] + 2] <= write_data[23:16];
                    dmem[address[11:0] + 3] <= write_data[31:24];
                end
            end
            
            if (read_enable) begin
                if (byte_enable) begin
                    read_data <= {24'b0, dmem[address[11:0]]};
                end else begin
                    read_data <= {dmem[address[11:0] + 3], dmem[address[11:0] + 2], 
                                 dmem[address[11:0] + 1], dmem[address[11:0]]};
                end
            end else begin
                read_data <= 32'b0;
            end
        end
    end

endmodule
