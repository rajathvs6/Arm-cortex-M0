
// ====================
// SHIFTER MODULE
// ====================
module shifter (
    input wire [31:0] data_in,
    input wire [4:0] shift_amount,
    input wire [1:0] shift_type,
    input wire carry_in,
    output reg [31:0] data_out,
    output reg carry_out
);

localparam LSL = 2'b00;
localparam LSR = 2'b01;
localparam ASR = 2'b10;
localparam ROR = 2'b11;

always @(*) begin
    carry_out = carry_in;
    
    case (shift_type)
        LSL: begin
            if (shift_amount == 0) begin
                data_out = data_in;
            end else if (shift_amount < 32) begin
                data_out = data_in << shift_amount;
                carry_out = data_in[32 - shift_amount];
            end else begin
                data_out = 32'b0;
                carry_out = (shift_amount == 32) ? data_in[0] : 1'b0;
            end
        end
        LSR: begin
            if (shift_amount == 0) begin
                data_out = 32'b0;
                carry_out = data_in[31];
            end else if (shift_amount < 32) begin
                data_out = data_in >> shift_amount;
                carry_out = data_in[shift_amount - 1];
            end else begin
                data_out = 32'b0;
                carry_out = (shift_amount == 32) ? data_in[31] : 1'b0;
            end
        end
        ASR: begin
            if (shift_amount == 0) begin
                data_out = data_in[31] ? 32'hFFFFFFFF : 32'b0;
                carry_out = data_in[31];
            end else if (shift_amount < 32) begin
                // Arithmetic right shift
                if (data_in[31]) begin // negative number
                    data_out = (data_in >> shift_amount) | (~(32'hFFFFFFFF >> shift_amount));
                end else begin // positive number
                    data_out = data_in >> shift_amount;
                end
                carry_out = data_in[shift_amount - 1];
            end else begin
                data_out = data_in[31] ? 32'hFFFFFFFF : 32'b0;
                carry_out = data_in[31];
            end
        end
        ROR: begin
            if (shift_amount == 0) begin
                data_out = {carry_in, data_in[31:1]};
                carry_out = data_in[0];
            end else begin
                data_out = (data_in >> shift_amount) | (data_in << (32 - shift_amount));
                carry_out = data_in[shift_amount - 1];
            end
        end
    endcase
end

endmodule
