`timescale 1ns / 1ps


module regfile(
input clk,
input rst,
input we,
input [4:0] raddr1,
input [4:0] raddr2,
input [4:0] waddr,
input [31:0] wdata,
output [31:0] rdata1,
output [31:0] rdata2
    );
reg [31:0] array_reg[31:0];
integer i;

always@(posedge clk,posedge rst)
begin
  if(rst)
  begin
    i=0;
    while(i<32)
    begin
      array_reg[i]=i;
      i=i+1;
    end
  end
  else if(we & (waddr!=0))
  begin
    $display("write regfile: before: $%d = %d", waddr, array_reg[waddr]);
    array_reg[waddr]=wdata;
    $display("                       $%d = %d", waddr, array_reg[waddr]);
  end
end

assign rdata1=array_reg[raddr1];
assign rdata2=array_reg[raddr2];

endmodule
