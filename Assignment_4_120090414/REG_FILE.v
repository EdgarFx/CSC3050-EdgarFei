// This file implements the register file of MIPS CPU.

`timescale 1ns / 1ps

module reg_file(
    input wire ENABLE,
    input wire[31:0] PC, // used to store the next instruction address to $31
    input wire[4:0] A1,  // the number of rs
    input wire[4:0] A2,  // the number of rt
    input wire[4:0] A3, // the number of the register to be written
    input wire[31:0] WD3,  // the write back data
    input wire[0:0] RegWriteW, // whether write data back to register file.
    input wire[0:0] JumpD,  // whether jump

    output reg[31:0] RD1,
    output reg[31:0] RD2
);

reg[31:0] registers[31:0];  // 32 general registers which is 32 bits for each register

always @ (ENABLE)   // initialize the values of the general registers
begin
    registers[0] = 32'h0000_0000;
    registers[8] = 32'h0000_0008;
    registers[9] = 32'h0000_0009;
    registers[10] = 32'h0000_000a;
    registers[11] = 32'h0000_000b;
    registers[12] = 32'h0000_000c;
    registers[13] = 32'h0000_000d;
    registers[14] = 32'h0000_000e;
    registers[15] = 32'h0000_000f;
    registers[16] = 32'h0000_0010;
    registers[17] = 32'h0000_0011;
    registers[18] = 32'h0000_0012;
    registers[19] = 32'h0000_0013;
    registers[20] = 32'h0000_0014;
    registers[21] = 32'h0000_0015;
    registers[22] = 32'h0000_0016;
    registers[23] = 32'h0000_0017;
    registers[24] = 32'h0000_0018;
    registers[25] = 32'h0000_0019;
end


// write data back when RegWriteW is 1 and at the posedge of the clock
always @ (WD3)
begin
    if (RegWriteW)
        begin
            registers[A3] = WD3;
        end
end

always @ (A1, A2)
begin
    RD1 = registers[A1];
    RD2 = registers[A2];
end

always @ (JumpD)
begin
    if (JumpD)
        registers[31] = PC;
end


endmodule