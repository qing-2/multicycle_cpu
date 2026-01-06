`timescale 1ns / 1ps


module mux2x32#(parameter WIDTH=32)(
input [WIDTH-1:0] a,
input [WIDTH-1:0] b,
input select,
output reg [WIDTH-1:0] r
    );
    always @*
    begin
      case(select)
        1'b0:
          r=a;
        1'b1:
          r=b;
        default:
          r=32'b0;
      endcase
    end
endmodule
