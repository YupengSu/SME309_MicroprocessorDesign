`timescale 1ns / 1ps

module Control_tb;
    // Inputs
    reg clk;
    reg rst_n;
    reg btn_p;
    reg btn_spdup;
    reg btn_spddn;

    // Outputs
    wire [7:0] addr;
    wire [7:0] led_data;
    
    // Instantiate the Unit Under Test (UUT)
    Control uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .btn_p(btn_p), 
        .btn_spdup(btn_spdup), 
        .btn_spddn(btn_spddn), 
        .addr(addr), 
        .led_data(led_data)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    initial begin
        // Initialize Inputs
        rst_n = 0;
        btn_p = 1;
        btn_spdup = 1;
        btn_spddn = 1;

        #10 rst_n = 1;
        #10000000 btn_p = 0;
        #10000 btn_p = 1;
        #10000000 btn_p = 0;
        #10000 btn_p = 1;
        #10000000 btn_spdup = 0;
        #10000 btn_spdup = 1;
        #10000000 btn_spddn = 0;
        #10000 btn_spddn = 1;
        #10000000 btn_spddn = 0;
        #10000 btn_spddn = 1;
        #10000000 btn_spdup = 0;
        #10000 btn_spdup = 1;
    end

endmodule