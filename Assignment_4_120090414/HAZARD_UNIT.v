// This file implements the hazard unit

`timescale 1ns / 1ps

module hazard_unit(
    input wire[4:0] rsD,
    input wire[4:0] rtD,
    input wire[4:0] rsE,
    input wire[4:0] rtE,
    input wire[4:0] rdM,
    input wire[4:0] rdW,
    input wire[0:0] RegWriteM,
    input wire[0:0] RegWriteW,
    input wire[0:0] MemtoRegE,
    input wire[0:0] BranchM,
    input wire[0:0] zeroM,
    input wire[0:0] stall,

    output reg[1:0] ForwardAE,
    output reg[1:0] ForwardBE,
    output reg[0:0] stallF,
    output reg[0:0] stallD,
    output reg[0:0] flush
);

initial begin
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;
    stallF = 1'b0;
    stallD = 1'b0;
    flush = 1'b0;
end

// Forwarding Unit
always @ (rsE, rtE, rdM, rdW, RegWriteM, RegWriteW)
begin
    if(RegWriteM)
    begin
        // rs case
        if(rsE==rdM)   ForwardAE = 2'b01;  // EX/MEM forwarding
        else if(RegWriteW)
        begin
            if(rsE==rdW)   ForwardAE = 2'b10;  //  MEM/WB forwarding
            else
            begin
                ForwardAE = 2'b00;
            end
        end
        // rt case
        if(rtE==rdM)  ForwardBE = 2'b01;  //  EX/MEM forwarding
        else if(RegWriteW)
        begin
            if(rtE==rdW)   ForwardBE = 2'b10;  // MEM/WB forwarding
            else
            begin
                ForwardBE = 2'b00; 
            end 
        end 
    end
    else if(RegWriteW)  //if no EX/MEM forwarding, then it is possible to have MEM/WB forwarding
    begin
        // rs case
        if(rsE==rdW)  ForwardAE = 2'b10;
        else   ForwardAE = 2'b00;
        // rt case
        if(rtE==rdW) ForwardBE = 2'b10;
        else  ForwardBE = 2'b00;
    end
    else
    begin
        ForwardAE = 2'b00;
        ForwardBE = 2'b00; 
    end
end

// handlng stalls
always @ (rsD, rtD, rsE, rtE, MemtoRegE, stall)
begin
    if(MemtoRegE)  // lw instr
    begin
        if(rsD==rtE||rtD==rtE)
        begin
            stallF = 1'b1;
            stallD = 1'b1; 
        end
        else
        begin
            stallF = 1'b0;
            stallD = 1'b0; 
        end
    end
    else
    begin
        stallF = 1'b0;
        stallD = 1'b0;
    end
end

//Branch hazards
always @ (BranchM, zeroM)
begin
    if(BranchM && zeroM)  flush = 1'b1;
    else  flush = 1'b0;
end



endmodule