// This file is used to test
`include "CPU.v"

`timescale 1ns / 1ps
module CPU_test;

    // CPU Inputs
	reg clock;
    reg ENABLE;    
	wire [31:0] d_datain;              // need to be wire type to accept the output from memories
	wire [31:0] i_datain;
    // CPU outputs
    wire [31:0] d_dataout;
    wire [31:0] d_addr;
    wire [31:0] i_addr;
    wire [0:0]  MemWrite;


    cpu uut(
        .CLK(clock),
        .ENABLE(ENABLE), 
		.data(d_datain), 
		.instruciton(i_datain),

        .out_data(d_dataout),
        .data_address(d_addr),
        .ins_address(i_addr),
        .MemWrite(MemWrite)
    );


    InstructionRAM i_mem(
        .CLK(clock),
        .addr(i_addr),

        .out(i_datain)
        );

    MainMemory d_mem(
        .CLK(clock),
        .addr(d_addr),
        .storeW(d_dataout),
        .store(MemWrite),

        .out(d_datain)
        );



    initial begin
        // Initialize Inputs - i_datain here represents the instruction stored at location 0x0000_0000
        clock = 0;
        ENABLE = 1;

    $display("\n");
    $display("CLK:                  IF                     :          DE        :           EX             :               MEM              :    WB    :                           Others                             :");
    $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
    $display("CLK:   pc   :        instruction             :rs_num:rt_num:ALUCon: reg_a  : reg_b  : reg_C  :ALUOutM : WriteDataM : ReadData : wb_data  :d_datain:forward_A:forward_B:stallF:stallD:");
    $monitor(" %b :%h:%b:  %h  :  %h  :  %h   :%h:%h:%h:%h:  %h  : %h : %h :%h:    %b   :   %b    :  %b   :  %b   :", clock,
        uut.pc, uut.instrF, uut.A1, uut.A2, uut.ALUControlD, uut.reg_valueA, uut.reg_valueB, uut.result, uut.ALUOutM, uut.WriteDataM, uut.ReadData, uut.ResultW, d_datain, 
        uut.ForwardAE, uut.ForwardBE, uut.stallF, uut.stallD);

    end

    always @(posedge clock) begin
        $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
    end


    // the finishing condition is determined by the length of test file
    always @(posedge !clock) begin
        if (i_addr >= 32'h0000_0090 || i_addr == 32'bx) begin
            $finish;
        end
        end



parameter period = 10;

always #5 clock = ~clock;

endmodule

