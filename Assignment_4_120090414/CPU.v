// This file implements a pipelined CPU

`include "REG_FILE.v"
`include "ALU.v"
`include "CONTROL_UNIT.v"
`include "HAZARD_UNIT.v"
`include "instructionRAM.v"
`include "MainMemory.v"

`timescale 1ns / 1ps

module cpu(
    input wire clock,
    input wire ENABLE,
    input wire[31:0] instruciton,
    input wire[31:0] data,

    output wire[31:0] out_data,
    output wire[31:0] ins_address,
    output wire[31:0] data_address,
    output wire MemWrite
);

// control signals in DE stage
wire[0:0] RegWriteD;
wire[0:0] MemWriteD;
wire[0:0] MemtoRegD;
wire[0:0] JumpD;
wire[0:0] RegDstD;
wire[0:0] BranchD;
wire[3:0] ALUControlD;

// control signals in EX stage
reg[0:0] RegWriteE;
reg[0:0] MemWriteE;
reg[0:0] MemtoRegE;
reg[0:0] RegDstE;
reg[0:0] BranchE;
reg[3:0] ALUControlE;
reg[4:0] WriteRegE;

// control signals in MEM stage
reg[0:0] RegWriteM;
reg[0:0] MemtoRegM;
reg[0:0] BranchM;
reg[0:0] PCSrcM;

// control signals in WB stage
reg[0:0] RegWriteW;
reg[0:0] MemtoRegW;


// data in IF stage
reg[31:0] PC = 32'h0000_0000;
reg[31:0] InstrF;

// data in DE stage
reg[4:0] A1;
reg[4:0] A2;
reg[4:0] A3;
reg[5:0] opcode;
reg[5:0] funct;
reg[4:0] shamt;
reg[15:0] immediate;
reg[25:0] j_imm;
reg[31:0] PCPlus4D;
wire[31:0] RD1;
wire[31:0] RD2;
wire[31:0] regA;
wire[31:0] regB;
wire[31:0] extend_immediate;
wire[31:0] j_address;

// data in EX stage
reg[31:0] reg_valueA;
reg[31:0] reg_valueB;
reg[31:0] WriteDataE;
reg[31:0] Branch_pc;
wire[31:0] result;
wire[2:0] flags;

// data in MEM stage
reg[31:0] WriteDataM;
reg[31:0] ALUOutM;
reg[4:0] WriteRegM;
reg[31:0] ReadData;

// data in WB stage
reg[4:0] WriteRegW;
reg[31:0] ResultW;

// hazard unit
reg[4:0] rsE;
reg[4:0] rtE;
reg[0:0] stall;
wire[1:0] ForwardAE;
wire[1:0] ForwardBE;
wire[0:0] stallF;
wire[0:0] stallD;
wire[0:0] flushE;

reg_file REG_FILE(ENABLE,PC,A1,A2,WriteRegW,ResultW,RegWriteW,JumpD,RD1,RD2);
control_unit CONTROL_UNIT(opcode,funct,shamt,immediate,RD1,RD2,flushE,j_imm,j_address,
                        regA,regB,RegWriteD,MemtoRegD,MemWriteD,ALUControlD,BranchD,RegDstD,JumpD,extend_immediate);
alu ALU(ALUControlE,reg_valueA,reg_valueB,result,flags);
hazard_unit HAZARD_UNIT(instrF[25:21],instrF[20:16],rsE,rtE,WriteRegM,WriteRegW,MemtoRegE,BranchM,flags[2],stall,ForwardAE,ForwardBE,stallF,stallD,flushE);


// update PC
always @ (posedge clock)
begin
    if(!stallF)  // if there is stalling, just keep the same.
    begin
        if(BranchE&&flags[2])
        begin
            PC <= Branch_pc; // have branch and zero flag is 1
        end
        else if(JumpD)  // need to jump
        begin
            PC <= j_address; 
        end
        else
        begin
            PC <= PC + 32'h0000_0004; //normal case, just plus 4
        end
    end 
end

InstructionRAM ins_ram(clock,1'b0,ENABLE, PC>>2, InstrF);

// instruction fetching
always @ (posedge clock)
begin
    if(!stallF)
    begin
        instrF <= insturction[31:0];
        if(BranchE&&flags[2])
        begin
            instrF <= 32'b0;  // if need to branch, then stalling
        end
        if(JumpD)  // if need to jump, then stalling
        begin
            instrF <= 32'b0; 
        end
    end 
end

// instruction decoding
always @ (posedge clock)
begin
    if(!stallD)
    begin
        A1 <= instrF[25:21];
        A2 <= instrF[20:16];
        A3 <= instrF[15:11];
        opcode <= instrF[31:26];
        funct <= instrF[5:0];
        shamt <= instrF[10:6];
        immediate <= instrF[15:0];
        j_imm <= instrF[25:0];
        PCPlus4D <= PC;
    end
    else
    begin
        stall <= stallD; 
    end
end

// EX stage
always @ (posedge clock)
begin
    rsE <= A1;
    rtE <= A2;
    // rs forwarding multiplexer
    if(ForwardAE == 2'b00)  reg_valueA <= regA;  
    else if(ForwardAE == 2'b01)  reg_valueA <= result; // EX/MEM forwarding for rs
    else if(ForwardAE == 2'b10)  // MEM/WB forwarding for rs
    begin
        if(MemtoRegM)  reg_valueA <= data;
        else    reg_valueA <= ALUOutM;
    end
    else   reg_valueA <= regA;  // since there may be no value in MEM and WB stage

    if(ForwardBE == 2'b00)   reg_valueB <= regB;  
    else if(ForwardBE == 2'b01)   reg_valueB <= result;  // EX/MEM forwarding for rt
    else if(ForwardBE == 2'b10)  // MEM/WB forwarding for rt
    begin
        if(MemtoRegM)   reg_valueB <= data;
        else     reg_valueB <= ALUOutM;
    end
    else     reg_valueB <= regB;
    ALUControlE <= ALUControlD;
    RegWriteE <= RegWriteD;
    MemtoRegE <= MemtoRegD;
    MemWriteE <= MemWriteD;
    BranchE <= BranchD;
    WriteDataE <= RD2;
    Branch_pc <= PCPlus4D + (extend_immediate<<2);
    if(RegDstD) WriteRegE <= A3;  // choose the destinate register
    else   WriteRegE <= A2;
end

// MEM stage
always @ (posedge clock)
begin
    RegWriteM <= RegWriteE;
    MemtoRegM <= MemtoRegE;
    WriteRegM <= WriteRegE;
    ALUOutM <= result;
    if(MemWriteE)  // sw
    begin
        WriteDataM <= WriteDataE;
    end
    ReadData <= data; // lw
end

MainMemory main_memory(clock, 1'b0, MemWriteE, ALUOutM>>2, {MemWriteE,ALUOutM[31:0]>>2,WriteDataM[31:0]}, ReadData);

// WB stage
always @ (posedge clock)
begin
    RegWriteW <= RegWriteM;
    WriteRegW <= WriteRegM;
    if(MemtoRegM) ResultW <= ReadData;
    else ResultW <= ALUOutM;
end

//flushing
always @ (flushE)
begin
    if(flushE&&!stall)
    begin
        instrF = 32'b0;
        A1 = 5'b0;
        A2 = 5'b0;
        A3 = 5'b0;
        opcode = 6'b0;
        funct <= 6'b0;
        immediate <= 16'b0;
        PCPlus4D = 32'b0;
    end
end

always @ (JumpD,j_address)
begin
    if(JumpD&&!stallF)
    begin
        instrF = 32'b0;
    end
end

assign ins_address = result;
assign data_address = PC;
assign MemWrite = MemWriteE;
assign out_data = WriteDataE;

/* Beginning */
integer clock_cycle=0;  // Record the clock cycle

initial begin
    clock = 0;
    ENABLE = 0;
    #4000;
    clock = 1;
    ENABLE = 1;
    clock_cycle = 0;
end

integer i;
integer final_cycle=0, flag=0;
always @(negedge(CLK)) begin
    #900;
    clock_cycle = clock_cycle + 1;
    if (InstrF == 32'b11111111111111111111111111111111)
        flag = 1;
    if (flag==1)
        final_cycle = final_cycle+1;
    if (final_cycle>=5)  // the last instruction is finished
    // display the whole Main Memory
    begin
        i = 0;
        while(i<512)
        begin
            $display("%b", main_memory.DATA_RAM[i]);
            i = i + 1;
        end
        $display("Clock cycles: %d", clock_cycle);
        $finish;
    end
end

endmodule