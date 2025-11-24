`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/25 00:07:41
// Design Name: 
// Module Name: cpu
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


module cpu(
input clk,
input [31:0] inst,
input reset,
input [31:0] mrdata,

output [31:0] pc_out,
output [31:0] maddr,
output [31:0] mwdata,
output IM_R,
output DM_CS,
output DM_R,
output DM_W,
output [31:0]alu_r  
    );
    
wire RF_W,M1,M2,M3,M4,M5,M6,sign_ext,zero;
wire [2:0] ALUC;
wire [31:0] alu_input_a, alu_input_b;
wire[31:0] mux1_out,mux2_out,alu_out;
wire [31:0] rf_rdata1,rf_rdata2;
wire [31:0] ext5_out,ext16_out,ext18_out;
wire [31:0] npc_out;
wire [31:0] join_out;
wire [27:0] imm16_offset;
    
assign alu_r = alu_out_reg;
assign maddr = alu_out_reg;
assign mwdata = rf_rdata2;
assign imm16_offset = IR_reg[15:0]<<2;

assign npc_out = alu_out_reg; // calculated in alu, instead of NPC module

decoder cpu_decoder(IR_reg, clk, zero, addu, subu, ori, sll, lw, sw, beq, j_i);

controller cpu_controller(clk, reset,zero, addu, subu, ori, sll, lw, sw, beq, j_i,
                          PC_W, IR_W, RF_W, ALUOut_W,
                          ALU_A_Sel, ALU_B_Sel, ALUC,
                          MemtoReg, IM_R, DM_R, DM_W, DM_CS,
                          sign_ext);

PC cpu_pc(clk,reset,PC_W,mux1_out,pc_out);

JOIN cpu_join(inst[25:0] << 2, pc_out[31:28],join_out);

regfile cpu_regfile(clk,reset,RF_W,IR_reg[25:21],IR_reg[20:16], RF_W,mux2_out,rf_rdata1,rf_rdata2);

alu cpu_alu(alu_input_a,alu_input_b,ALUC,alu_out,zero);

ext5 cpu_ext5(IR_reg[10:6], ext5_out);               // shift amount 扩展
ext16 cpu_ext16(IR_reg[15:0], sign_ext, ext16_out);  // immediate 扩展
ext18 cpu_ext18(imm16_offset, ext18_out);            // beq offset 扩展

mux2x32 mux1(npc_out, join_out, j_i,mux1_out); // for J instruction   

mux2x32 mux2(alu_out_reg, mrdata, MemtoReg, mux2_out);

// ALU输入端选择
assign alu_input_a = 
    (ALU_A_Sel == 2'b00) ? pc_out :
    (ALU_A_Sel == 2'b01) ? rs_reg :
    (ALU_A_Sel == 2'b10) ? ext5_out : 32'b0;

assign alu_input_b = 
    (ALU_B_Sel == 2'b00) ? rt_reg :
    (ALU_B_Sel == 2'b01) ? 32'd4 :
    (ALU_B_Sel == 2'b10) ? ext16_out :
    (ALU_B_Sel == 2'b11) ? ext18_out : 32'b0;
    

// 为了分段，相较于单周期CPU需要额外添加寄存器
reg [31:0] IR_reg;         // 指令寄存器
reg [31:0] rs_reg, rt_reg; // 操作数寄存器  
reg [31:0] alu_out_reg;    // ALU结果寄存器
reg [31:0] MDR_reg;        // 内存数据寄存器

always @(posedge clk) begin
    if (reset) begin
        IR_reg <= 32'b0;
        rs_reg <= 32'b0;
        rt_reg <= 32'b0;
        alu_out_reg <= 32'b0;
        MDR_reg <= 32'b0;
    end else begin
        if (IR_W) 
            IR_reg <= inst;
    
        rs_reg <= rf_rdata1;
        rt_reg <= rf_rdata2;

        if (ALUOut_W)
            alu_out_reg <= alu_out;
    
        if (lw)
            MDR_reg <= mrdata;
    end
end


endmodule
