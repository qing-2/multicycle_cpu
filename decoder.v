`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/23 17:37:47
// Design Name: 
// Module Name: decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decoder(
input [31:0] inst,
input clk,
input zero,
output addu, subu, ori, sll, lw, sw, beq, j_i
    );
    
wire [5:0] func=inst[5:0];  
wire [5:0] op=inst[31:26];
wire r_type=~|op;
wire addu,subu,ori,sll,lw,sw,beq,j_i;
    
assign addu=r_type &func[5]&~func[4]&~func[3]&~func[2]&~func[1]&func[0];
assign subu=r_type &func[5]&~func[4]&~func[3]&~func[2]&func[1]&func[0];    
assign ori=~op[5]&~op[4]&op[3]&op[2]&~op[1]&op[0];
assign sll=r_type &~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
assign lw=op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0];
assign sw=op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0];
assign beq=~op[5]&~op[4]&~op[3]&op[2]&~op[1]&~op[0];
assign j_i=~op[5]&~op[4]&~op[3]&~op[2]&op[1]&~op[0];


endmodule
