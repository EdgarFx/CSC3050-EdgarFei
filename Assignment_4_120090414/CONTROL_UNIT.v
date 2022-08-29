// This file implements the main control unit and the ALU control unit
// I also do the immediate extension in the following module.

`timescale 1ns / 1ps

module control_unit(opcode,funct,shamt,immediate,RD1,RD2,
                    flushE,j_imm,j_address,regA,regB,RegWriteD,MemtoRegD,MemWriteD,ALUControlD,BranchD,RegDstD,JumpD,extend_immediate);

input wire clock;
input wire[5:0] opcode;
input wire[5:0] funct;
input wire[4:0] shamt;
input wire[15:0] immediate;
input wire[31:0] RD1;
input wire[31:0] RD2;
input wire[0:0] flushE;
input wire[25:0] j_imm;

output reg[31:0] j_address;
output signed[31:0] regA, regB;
output reg[0:0] RegWriteD;
output reg[0:0] MemtoRegD;
output reg[0:0] MemWriteD;
output reg[3:0] ALUControlD;
output reg[0:0] BranchD;
output reg[0:0] RegDstD;
output reg[0:0] JumpD;
output reg[31:0] extend_immediate;

reg[31:0] reg_valueA;
reg[31:0] reg_valueB;
reg[31:0] imm_ext;

wire[0:0] sign = (opcode==6'b001100||opcode==6'b001101||opcode==6'b001110) ? 1'b0 : 1'b1;


// get the RegWriteD signal
// except J, JAL, JR , BEQ, BNE instructions, the signal of others should be 1
always @ (opcode,funct,shamt,immediate)
begin
    case(opcode)
        6'b000000:  // R-type instr
            case(funct)
                6'b001000: RegWriteD = 1'b0;  //JR
                default: RegWriteD = 1'b1;
            endcase
        6'b000010,6'b000011,6'b000100,6'b000101: RegWriteD = 1'b0;  //J,JAL,BEQ,BNE
        default: RegWriteD = 1'b1;
    endcase
end

// get the MemtoRegD signal
always @ (opcode,funct,shamt,immediate)
begin
    case(opcode)
        6'b100011: MemtoRegD = 1'b1;  // lw
        default: MemtoRegD = 1'b0;
    endcase 
end

// get the MemWriteD signal
always @ (opcode, funct, shamt, immediate)
begin
    case(opcode)
        6'b101011: MemWriteD = 1'b1;  // sw
        default: MemWriteD = 1'b0;
    endcase
end

// get the BranchD signal
always @ (opcode, funct, shamt, immediate)
begin
    case(opcode)
        6'b000100,6'b000101: BranchD = 1'b1;
        default: BranchD = 1'b0;
    endcase
end

// get the ALUControlD signal
always @ (opcode, funct, shamt, immediate)
begin
    case(opcode)
        6'b000000:   // R-type
        begin
            case(funct)
                6'b100000: ALUControlD = 4'b0010; //add
                6'b100001: ALUControlD = 4'b0010; //addu
                6'b100010: ALUControlD = 4'b0010; //sub
                6'b100011: ALUControlD = 4'b0010; //subu
                6'b100100: ALUControlD = 4'b0100; //and
                6'b100101: ALUControlD = 4'b0101; //or
                6'b100111: ALUControlD = 4'b0111; //nor
                6'b100110: ALUControlD = 4'b0110; //xor
                6'b101010: ALUControlD = 4'b1011; //slt
                6'b000000: ALUControlD = 4'b1110; //sll
                6'b000100: ALUControlD = 4'b1110; //sllv
                6'b000010: ALUControlD = 4'b1101; //srl
                6'b000110: ALUControlD = 4'b1101; //srlv
                6'b000011: ALUControlD = 4'b1100; //sra
                6'b000111: ALUControlD = 4'b1100; //srav
                6'b001000: ALUControlD = 4'b1110; //jr
                default: ALUControlD = 4'b0000;
            endcase
        end
        6'b001000: ALUControlD = 4'b0010; //addi
        6'b001001: ALUControlD = 4'b0010; //addiu
        6'b001100: ALUControlD = 4'b0100; //andi
        6'b001101: ALUControlD = 4'b0101; //ori
        6'b001110: ALUControlD = 4'b0110; //xori
        6'b100011: ALUControlD = 4'b0010; //slti
        6'b101011: ALUControlD = 4'b0010; //sltiu
        6'b000100: ALUControlD = 4'b0010; //lw
        6'b000101: ALUControlD = 4'b0010; //sw
        6'b000100: ALUControlD = 4'b0010; //beq
        6'b000101: ALUControlD = 4'b0010; //bne
        6'b000010,6'b000011: ALUControlD = 4'b1110; //j,jal
        default: ALUControlD = 4'b0000;
    endcase
end

// get the RegDstD signal
always @ (opcode, funct, shamt, immediate)
begin
    case(opcode)
        6'b000000: // R-type
            case(funct)
                6'b100000,6'b100010,6'b100001,6'b100011,6'b100100,6'b100101,6'b100111,
                6'b100110,6'b000000,6'b000011,6'b000010,6'b000100,6'b000111,6'b000110,
                6'b101010: RegDstD = 1'b1; //add,sub,addu,subu,and,or,nor,xor,sll,sra,srl,sllv,srav,srlv,slt   they use rd
                default: RegDstD = 1'b0;
            endcase
        6'b100011,6'b101011,6'b001000,6'b001001,6'b001100,6'b001101: RegDstD = 1'b0; //lw,sw,addi,addiu,andi,ori   they use rt
        default: RegDstD = 1'b0;  //beq,bne,j,jr,jal
    endcase
end

// get the JumpD signal
always @ (opcode, funct, shamt, immediate)
begin
    case(opcode)
        6'b000000: // R-type
            case(funct)
                6'b001000:
                    begin
                        j_address = RD1;
                        JumpD = 1'b1;    
                    end
                default: JumpD = 1'b0;
            endcase
        6'b000010,6'b000011:
            begin
                j_address = {6'b000000,j_imm};
                JumpD = 1'b1;
            end
        default: JumpD = 1'b0;
    endcase
end

// data modification (extension, multiplexer......)
always @ (opcode, funct, shamt, immediate, RD1, RD2)
begin
    if(opcode==6'b000000)
    begin
        if(funct==6'b000000||funct==6'b000010||funct==6'b000011) //sll,srl,sra
        begin
            reg_valueA = RD2;
            reg_valueB = {27'b0,shamt};
        end
        else if(funct==6'b100010||funct==6'b100011) //sub,subu  change to reuse the add logic in ALU
        begin
            reg_valueA = RD1;
            reg_valueB = (~RD2)+1;
        end
        else if(funct==6'b001000)  //jr,   flushing
        begin
            reg_valueA = 32'b0;
            reg_valueB = 32'b0;
        end
        else
        begin
            reg_valueA = RD1;
            reg_valueB = RD2;
        end
    end
    else if(opcode==6'b000100)  //beq
    begin
        reg_valueA = RD1;
        reg_valueB = (~RD2)+1;
    end
    else if(opcode==6'b000101)  //bne   change to reuse the beq logic in ALU
    begin
        if(RD1==RD2)
        begin
            reg_valueA = RD1;
            reg_valueB = ~RD2; 
        end
        else
        begin
            reg_valueA = RD1;
            reg_valueB = (~RD1) + 1; 
        end
    end
    else if(opcode==6'b101011||opcode==6'b100011) //sw,lw
    begin
        reg_valueA = RD1;
        reg_valueB = (sign?{{16{immediate[15]}},immediate[15:0]}:{{16{1'b0}},immediate[15:0]})*4;
    end
    else if(opcode==6'b000010||opcode==6'b000011)  //j,jal-----flushing
    begin
        reg_valueA = 32'b0;
        reg_valueB = 32'b0; 
    end
    else if(opcode!=6'b000000)
    begin
        reg_valueA = RD1;
        reg_valueB = sign?{{16{immediate[15]}},immediate[15:0]}:{{16{1'b0}},immediate[15:0]};
    end
    extend_immediate = sign?{{16{immediate[15]}},immediate[15:0]}:{{16{1'b0}},immediate[15:0]};
end

always @ (flushE)
begin
    if(flushE)
    begin
        extend_immediate = 32'b0;
        reg_valueA = 32'b0;
        reg_valueB = 32'b0;
        RegWriteD = 1'b0;
        MemtoRegD = 1'b0;
        MemWriteD = 1'b0;
        ALUControlD = 6'b000000;
        RegDstD = 1'b0;
        JumpD = 1'b0;
        j_address = 32'b0;
    end 
end

assign regA = reg_valueA;
assign regB = reg_valueB;


endmodule
