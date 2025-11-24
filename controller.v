`timescale 1ns / 1ps

module controller(
input clk,
input reset,
input zero,
input addu, subu, ori, sll, lw, sw, beq, j_i,
output PC_W, IR_W, RF_W, ALUOut_W,
output [1:0] ALU_A_Sel, ALU_B_Sel,
output [2:0] ALUC,
output MemtoReg,
output IM_R,
output DM_R,
output DM_W,
output DM_CS,
output sign_ext
    );


 /// part1. 状态机
parameter [3:0] IF  = 0, ID  = 1, EX  = 2, MEM = 3, WB  = 4, BRANCH = 5;

reg [2:0] state, next_state;
always @(posedge clk or posedge reset) begin
    if (reset) state <= IF;
    else state <= next_state;
end

always @(*) begin
    case (state)
        IF: next_state = ID;  // 取指后总是进入译码
        
        ID: begin
            if (lw | sw | addu | subu | ori | sll | beq)
                next_state = EX;
            else if (j_i) 
                next_state = IF;   // 无条件跳转指令直接更新PC
            else 
                next_state = IF;  // 不是支持的8条指令，不执行，取下一条指令
        end
        
        EX: begin
            if (lw | sw) 
                next_state = MEM;     // 访存指令去内存阶段
            else if (beq) 
                next_state = BRANCH;  // 判断跳转条件
            else 
                next_state = WB;      // 其他指令去写回
        end
        
        MEM: begin
            if (lw)
                next_state = WB;   // load指令去写回
            else 
                next_state = IF;   // store指令结束
        end
        
        BRANCH: next_state = IF;   // 分支指令结束
        
        WB: next_state = IF;       // 写回后结束
        
        default: next_state = IF;
    endcase
end



/// part2. 生成控制信号
wire sign_ext;
wire [1:0] ALU_A_Sel, ALU_B_Sel;
always @(*) begin
    // 默认值 - 所有信号置0
    PC_W   = 1'b0;
    IR_W   = 1'b0;
    DM_W       = 1'b0;  // Data Memory Write
    RF_W       = 1'b0;  // Register File Write
    ALUOut_W   = 1'b0;  // ALU Output Register Write
    ALU_A_Sel  = 2'b00;
    ALU_B_Sel  = 2'b00;
    ALUC       = 3'b000;
    MemtoReg   = 1'b0;
    IM_R       = 1'b0;
    DM_R       = 1'b0;
    DM_CS      = 1'b0;
    sign_ext   = 1'b0;

    case (state)
        IF: begin // Instruction Fetch
            // 取指阶段：PC→Mem→IR, PC+4→ALU_out
            IM_R = 1'b1;         // 用PC访问内存（取指令）
            IR_W = 1'b1;         // 写指令寄存器
            ALU_A_Sel = 2'b00;   // ALU输入A = PC
            ALU_B_Sel = 2'b01;   // ALU输入B = 4
            ALUC = 3'b010;       // ALU做加法 (PC+4)
            ALUOut_W = 1'b1;     // 保存ALU结果

            PC_W = 1'b1;          // 更新PC
        end

        ID: begin // Instruction Decode
            Rs_W = 1'b1;          // 读寄存器文件
            Rt_W = 1'b1;          // 读寄存器文件
        end

        EX: begin // Execution
            // 根据指令类型选择ALU输入A
            if (sll) 
                ALU_A_Sel = 2'b10;   // sll指令使用位扩展
            else
                ALU_A_Sel = 2'b01;   // rs_reg
            
            // 根据指令类型选择ALU输入B
            if (beq | addu | subu)
                ALU_B_Sel = 2'b00;   // rt_reg
            else if (lw | sw | ori) 
                ALU_B_Sel = 2'b10;   // 扩展立即数
            else if (beq)
                ALU_B_Sel = 2'b11;   // 扩展立即数

            if (lw | sw) 
                sign_ext = 1'b1;    // lw/sw 需要有符号扩展

            // ALU操作控制
            if (addu | lw | sw) 
                ALUC = 3'b000;  // 加
            else if (subu | beq) 
                ALUC = 3'b001;  // 减
            else if (ori) 
                ALUC = 3'b010;  // 或
            else if (sll) 
                ALUC = 3'b011;  // 移位

            // 等价于原单周期CPU中：
            // ALUC[2] = 0;
            // ALUC[1] = ori | sll;
            // ALUC[0] = subu | beq | sll;
            // sign_ext = lw | sw;

            ALUOut_W = ~j_i; // 保存ALU结果，直接进入下一阶段
        end

        MEM: begin // Memory Access
            DM_CS = 1'b1;
            if (sw) 
                DM_W = 1'b1;   // 写内存
            if (lw) 
                DM_R = 1'b1;   // 读内存
        end

        BRANCH: begin // BEQ: 比较寄存器并决定是否跳转
                ALU_A_Sel = 2'b01;  // rs_reg
                ALU_B_Sel = 2'b00;  // rt_reg  
                ALUC = 3'b001;      // 减
                ALUOut_W = 1'b0;
                if (zero)
                    PC_W = 1'b1;   // 条件成立则跳转，覆盖PC
        end

        WB: begin // Write Back
            RF_W = 1'b1;       // 允许写寄存器文件
            if (lw) 
                MemtoReg = 1'b1;   // lw: 从内存数据写回
            else 
                MemtoReg = 1'b0;   // 其他: 从ALU结果写回
        end
    endcase
end


endmodule
