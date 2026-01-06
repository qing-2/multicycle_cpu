`timescale 1ns / 1ps



module ext16#(parameter DEPTH=16)(
input [DEPTH-1:0] a,
input sign_ext,
output reg [31:0] b
    );
always@(a or sign_ext)
begin
  if(sign_ext==1 && a[DEPTH-1]==1)
  begin
    b[31:0]=32'hffffffff;
    b[DEPTH-1:0]=a[DEPTH-1:0];
  end
  else
  begin
     b[31:0]=32'h00000000;
     b[DEPTH-1:0]=a[DEPTH-1:0];
  end
end
endmodule
