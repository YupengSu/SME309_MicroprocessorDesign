    module Top (
    input clk, // input clk (frequency 100 Mhz)
    input rst_n, // input rst

    input btn_p, // pause button
    input btn_spdup, // speed up button
    input btn_spddn, // speed down button
    
    output [7:0] anode, // anodes for 7 segment
    output [6:0] cathode, // cathodes for 7 segment
    output dp, // dot point for 7 segment
    output [7:0] led_data // output addr by led
);

wire [7:0] addr;
wire [31:0] data;

Control u_ctrl (
    .clk(clk),
    .rst_n(rst_n), 
    .btn_p(btn_p), 
    .btn_spdup(btn_spdup), 
    .btn_spddn(btn_spddn), 
    .addr(addr), 
    .led_data(led_data)
);

Memory u_mem(
	.clk(clk),
	.rst_n(rst_n),
	.mem_addr(addr),
	.data(data)
);

Seg_Display u_seg (
    .clk(clk),
    .rst_n(rst_n),
    .data(data),
    .anode(anode),
    .cathode(cathode),
    .dp(dp)
);
    
endmodule