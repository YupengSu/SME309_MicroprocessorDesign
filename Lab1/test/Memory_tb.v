`timescale 1ns / 1ps
`include "Lab1/src/Memory.v"

module Memory_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg [7:0] mem_addr;

    // Outputs
    wire [31:0] data;

    // Instantiate the Unit Under Test (UUT)
    Memory uut (
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr(mem_addr),
        .data(data)
    );

    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end
    initial begin
        // Initialize Inputs
        rst_n = 0;
        mem_addr = 0;

        #10 rst_n = 1;
        #1000 mem_addr = 1;
        #1000 mem_addr = 2;
        #1000 mem_addr = 3;
        #1000 mem_addr = 4;
        #1000 mem_addr = 5;
        #1000 mem_addr = 6;
        #1000 mem_addr = 7;
    end


endmodule