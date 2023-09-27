`timescale 1ns / 1ps

module Seg_Display_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg [31:0] data;

    // Outputs
    wire [7:0] anode;
    wire [6:0] cathode;
    wire dp;

    // Instantiate the Unit Under Test (UUT)
    Seg_Display uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .data(data), 
        .anode(anode), 
        .cathode(cathode), 
        .dp(dp)
    );

    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end

    initial begin
        // Initialize Inputs
        rst_n = 0;
        data = 32'h12345678;
        #10 rst_n = 1;
    end


endmodule