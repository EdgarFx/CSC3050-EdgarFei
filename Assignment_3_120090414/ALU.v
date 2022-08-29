module alu(instruction, regA, regB, result, flags);

input[31:0] instruction, regA, regB;
output[31:0] result;
output[2:0] flags;

reg[5:0] opcode, funct;
reg[4:0] shamt;
reg signed[31:0] signed_rs, signed_rt, ALU_result;
reg[31:0] unsigned_rs, unsigned_rt;
reg[31:0] immediate;
reg[2:0] flags;
reg[4:0] rs;
reg[4:0] rt;
reg check_bit; //it is used to check the overflow


always @ (instruction, regA, regB)
begin
    opcode = instruction[31:26];
    shamt = instruction[10:6];
    funct = instruction[5:0];
    immediate = {{16{instruction[15]}},instruction[15:0]};
    rs = instruction[25:21];
    rt = instruction[20:16];

    if (opcode==6'b000000)
    begin
        //add
        if (funct==6'h20)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            {check_bit, ALU_result} = {signed_rs[31],signed_rs} + {signed_rt[31],signed_rt};
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = check_bit ^ ALU_result[31];
        end
        //addu
        else if (funct==6'h21)
        begin
            if (rs==5'b00000)
            begin
                unsigned_rs = regA;
                unsigned_rt = regB;
            end
            else
            begin
                unsigned_rs = regB;
                unsigned_rt = regA;
            end
            ALU_result = unsigned_rs + unsigned_rt;
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //sub
        else if (funct==6'h22)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            {check_bit, ALU_result} = {signed_rs[31],signed_rs} - {signed_rt[31],signed_rt};
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = check_bit ^ ALU_result[31];
        end
        //subu
        else if (funct==6'h23)
        begin
            if (rs==5'b00000)
            begin
                unsigned_rs = regA;
                unsigned_rt = regB;
            end
            else
            begin
                unsigned_rs = regB;
                unsigned_rt = regA;
            end
            ALU_result = unsigned_rs - unsigned_rt;
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //and
        else if (funct==6'h24)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            ALU_result = signed_rs & signed_rt;
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //nor
        else if (funct==6'h27)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            ALU_result = ~(signed_rs | signed_rt);
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //or
        else if (funct==6'h25)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            ALU_result = signed_rs | signed_rt;
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //xor
        else if (funct==6'h26)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            ALU_result = signed_rs ^ signed_rt;
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //slt
        else if (funct==6'h2a)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            ALU_result = signed_rs - signed_rt;
            flags[2] = 1'b0;
            if (signed_rs<signed_rt)
            begin
                flags[1] = 1;
            end
            else
            begin
                flags[1] = 0;
            end
            flags[0] = 1'b0;
        end
        //sltu
        else if (funct==6'h2b)
        begin
            if (rs==5'b00000)
            begin
                unsigned_rs = regA;
                unsigned_rt = regB;
            end
            else
            begin
                unsigned_rs = regB;
                unsigned_rt = regA;
            end
            ALU_result = unsigned_rs - unsigned_rt;
            flags[2] = 1'b0;
            if (unsigned_rs<unsigned_rt)
            begin
                flags[1] = 1;
            end
            else
            begin
                flags[1] = 0;
            end
            flags[0] = 1'b0;
        end
        //sll
        else if (funct==6'h00)
        begin
            if (rt==5'b00000)
            begin
                signed_rt = regA;
            end
            else
            begin
                signed_rt = regB;
            end
            ALU_result = signed_rt << {{27{1'b0}},shamt};
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //sllv
        else if (funct==6'h04)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            ALU_result = signed_rt << signed_rs[4:0];
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //srl
        else if (funct==6'h02)
        begin
            if (rt==5'b00000)
            begin
                signed_rt = regA;
            end
            else
            begin
                signed_rt = regB;
            end
            ALU_result = signed_rt >> {{27{1'b0}},shamt};
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //srlv
        else if (funct==6'h06)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            ALU_result = signed_rt >> signed_rs[4:0];
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //sra
        else if (funct==6'h03)
        begin
            if (rt==5'b00000)
            begin
                signed_rt = regA;
            end
            else
            begin
                signed_rt = regB;
            end
            ALU_result = signed_rt >>> {{27{1'b0}},shamt};
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
        //srav
        else if (funct==6'h07)
        begin
            if (rs==5'b00000)
            begin
                signed_rs = regA;
                signed_rt = regB;
            end
            else
            begin
                signed_rs = regB;
                signed_rt = regA;
            end
            ALU_result = signed_rt >>> signed_rs[4:0];
            flags[2] = 1'b0;
            flags[1] = 1'b0;
            flags[0] = 1'b0;
        end
    end
    //addi
    else if (opcode==6'b001000)
    begin
        if (rs==5'b00000)
        begin
            signed_rs = regA;
        end
        else
        begin
            signed_rs = regB;
        end
        {check_bit, ALU_result} = {signed_rs[31],signed_rs} + {immediate[31],immediate};
        flags[2] = 1'b0;
        flags[1] = 1'b0;
        flags[0] = check_bit ^ ALU_result[31];
    end
    //addiu
    else if (opcode==6'b001001)
    begin
        if (rs==5'b00000)
        begin
            unsigned_rs = regA;
        end
        else
        begin
            unsigned_rs = regB;
        end
        ALU_result = unsigned_rs + immediate;
        flags[2] = 1'b0;
        flags[1] = 1'b0;
        flags[0] = 1'b0;
    end
    //andi
    else if (opcode==6'b001100)
    begin
        if (rs==5'b00000)
        begin
            signed_rs = regA;
        end
        else
        begin
            signed_rs = regB;
        end
        immediate = {{16{1'b0}},instruction[15:0]};
        ALU_result = signed_rs & immediate;
        flags[2] = 1'b0;
        flags[1] = 1'b0;
        flags[0] = 1'b0;
    end
    //ori
    else if (opcode==6'b001101)
    begin
        if (rs==5'b00000)
        begin
            signed_rs = regA;
        end
        else
        begin
            signed_rs = regB;
        end
        immediate = {{16{1'b0}},instruction[15:0]};
        ALU_result = signed_rs | immediate;
        flags[2] = 1'b0;
        flags[1] = 1'b0;
        flags[0] = 1'b0;
    end
    //xori
    else if (opcode==6'b001110)
    begin
        if (rs==5'b00000)
        begin
            signed_rs = regA;
        end
        else
        begin
            signed_rs = regB;
        end
        immediate = {{16{1'b0}},instruction[15:0]};
        ALU_result = signed_rs ^ immediate;
        flags[2] = 1'b0;
        flags[1] = 1'b0;
        flags[0] = 1'b0;
    end
    //beq
    else if (opcode==6'b000100)
    begin
        if (rs==5'b00000)
        begin
            signed_rs = regA;
            signed_rt = regB;
        end
        else
        begin
            signed_rs = regB;
            signed_rt = regA;
        end
        ALU_result = signed_rs - signed_rt;
        flags[2] = (ALU_result==32'b0) ? 1 : 0;
        flags[1] = 1'b0;
        flags[0] = 1'b0;
    end
    //bne
    else if (opcode==6'b000101)
    begin
        if (rs==5'b00000)
        begin
            signed_rs = regA;
            signed_rt = regB;
        end
        else
        begin
            signed_rs = regB;
            signed_rt = regA;
        end
        ALU_result = signed_rs - signed_rt;
        flags[2] = (ALU_result==32'b0) ? 1 : 0;
        flags[1] = 1'b0;
        flags[0] = 1'b0;
    end
    //slti
    else if (opcode==6'b001010)
    begin
        if (rs==5'b00000)
        begin
            signed_rs = regA;
        end
        else
        begin
            signed_rs = regB;
        end
        ALU_result = signed_rs - $signed(immediate);
        flags[2] = 1'b0;
        if (signed_rs < $signed(immediate))
        begin
            flags[1] = 1;
        end
        else
        begin
            flags[1] = 0;
        end
        flags[0] = 1'b0;
    end
    //sltiu
    else if (opcode==6'b001011)
    begin
        if (rs==5'b00000)
        begin
            unsigned_rs = regA;
        end
        else
        begin
            unsigned_rs = regB;
        end
        ALU_result = unsigned_rs - $unsigned(immediate);
        flags[2] = 1'b0;
        if (unsigned_rs < $unsigned(immediate))
        begin
            flags[1] = 1;
        end
        else
        begin
            flags[1] = 0;
        end
        flags[0] = 1'b0;
    end
    //lw
    else if (opcode==6'b100011)
    begin
        if (rs==5'b00000)
        begin
            signed_rs = regA;
        end
        else
        begin
            signed_rs = regB;
        end
        ALU_result = signed_rs + $signed(immediate);
        flags[2] = 1'b0;
        flags[1] = 1'b0;
        flags[0] = 1'b0;
    end
    //sw
    else if (opcode==6'b101011)
    begin
        if (rs==5'b00000)
        begin
            signed_rs = regA;
        end
        else
        begin
            signed_rs = regB;
        end
        ALU_result = signed_rs + $signed(immediate);
        flags[2] = 1'b0;
        flags[1] = 1'b0;
        flags[0] = 1'b0;
    end
end

assign result = ALU_result[31:0];

endmodule