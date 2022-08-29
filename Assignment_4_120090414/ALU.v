// This file implements the ALU module, which is used in the EX stage.

`timescale 1ns / 1ps

module alu(regA,regB,ALUctr,result,flags);

input signed[3:0] ALUctr;
input signed[31:0] regA, regB;

output signed[31:0] result;
output signed[2:0] flags;  // The first bit (MSB) of flags is zero flag, the second bit is negative flag, the third bit is overflow flag.

reg[32:0] more_bit_res; // This more bit result is 33 bits, which is used to detect the overflow cases
reg[2:0] flags;

wire[3:0] ALUctr;

always @ (regA, regB, ALUctr)
begin
    case(ALUctr)
        4'b0010: more_bit_res = regA + regB;  // add case
        4'b0100: more_bit_res = regA & regB;  // and case
        4'b0101: more_bit_res = regA | regB;  // or case
        4'b0110: more_bit_res = regA ^ regB; // xor case
        4'b0111: more_bit_res = ~(regA | regB);  // nor case
        4'b1110: more_bit_res = regA << regB;  // sll case
        4'b1101: more_bit_res = $unsigned(regA) >> regB; // srl case
        4'b1100: more_bit_res = regA >>> regB; // sra case
        4'b1011: more_bit_res = (regA < regB) ? 1 : 0; // slt case
    endcase

    flags[2] = more_bit_res ? 0 : 1;  // zero flag
    flags[1] = more_bit_res[31];  // negative flag
    flags[0] = (more_bit_res[32]!=more_bit_res[31]) ? 1 : 0;  // overflow flag. When carry out of MSB does not equal to the carry in to MSB, then this flag is 1, which means overflow.
    
end

assign result = more_bit_res[31:0];

endmodule