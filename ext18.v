`timescale 1ns / 1ps



module ext18#(parameter DEPTH=18)(
input [DEPTH-1:0] a,
output reg [31:0] b
    );
    always@(a)
    begin
      if(a[DEPTH-1] == 1)//�з�����չ
            begin 
                b[31:0] = 32'hffffffff;
                b[DEPTH-1:0] = a[DEPTH-1:0];
            end
            else
            begin 
                b[31:0] = 32'h00000000;
                b[DEPTH-1:0] = a[DEPTH-1:0];
            end
    end
endmodule
