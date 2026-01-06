`timescale 1ns / 1ps


module alu(
input [31:0] a,
input [31:0] b,
input [2:0] aluc,
output [31:0] r,
output zero
    );
    
reg [31:0] r_1;

always@*
begin
  case(aluc)
  3'b000:
    r_1 = a + b;
  3'b001:
    r_1 = a - b;
  3'b010:
    r_1 = a | b;
  3'b011:
    r_1 = b << a[4:0];
  default:
    r_1 = 32'b0;
  endcase
end

assign r = r_1;
assign zero = r ? 1'b0 : 1'b1;
endmodule
