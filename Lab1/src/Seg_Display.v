module Seg_Display(
    input clk,
    input rst_n,

    input [31:0] data,
    
    output reg [7:0] anode, // seg_datas for 7 segment
    output reg [6:0] cathode, // cathodes for 7 segment
    output reg dp // dot point for 7 segment
);

// ===============================================
//            Counter: 1ms = 100 * 10ns
// ===============================================
reg [6:0] cnt;
reg switch_flag,switch_flag_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 7'd0;
        switch_flag <= 0;
    end
    else begin
        if (cnt == 7'd99) begin
            cnt <= 7'd0;
            switch_flag <= ~switch_flag;
        end
        else begin
            cnt <= cnt + 7'd1;
        end
    end
end

always @(posedge clk) begin
    switch_flag_r <= switch_flag;
end

// ===============================================
//           Position Selection Signal
// ===============================================
reg [2:0] pos_sel;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pos_sel <= 0;
    end
    else begin
        if (switch_flag != switch_flag_r) begin
            pos_sel <= pos_sel + 1;
        end
        else begin
            pos_sel <= pos_sel;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        anode <= 8'b11111111;
    end
    else begin
        case (pos_sel)
            3'b000: anode <= 8'b11111110;
            3'b001: anode <= 8'b11111101;
            3'b010: anode <= 8'b11111011;
            3'b011: anode <= 8'b11110111;
            3'b100: anode <= 8'b11101111;
            3'b101: anode <= 8'b11011111;
            3'b110: anode <= 8'b10111111;
            3'b111: anode <= 8'b01111111;
            default: anode <= 8'b11111111;
        endcase
    end
end

// ===============================================
//           Segment Selection Signal
// ===============================================
reg [3:0] seg_data;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seg_data <= 4'b0000;
    end
    else begin
        case (pos_sel)
            3'b000: seg_data <= data[3:0];
            3'b001: seg_data <= data[7:4];
            3'b010: seg_data <= data[11:8];
            3'b011: seg_data <= data[15:12];
            3'b100: seg_data <= data[19:16];
            3'b101: seg_data <= data[23:20];
            3'b110: seg_data <= data[27:24];
            3'b111: seg_data <= data[31:28];
            default: seg_data <= 4'b0000;
        endcase
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        {dp,cathode} <= 8'b11111111;
    end
    else begin
        case (seg_data)
            4'h0 : {dp,cathode} <= 8'b1100_0000;
            4'h1 : {dp,cathode} <= 8'b1111_1001;
            4'h2 : {dp,cathode} <= 8'b1010_0100;
            4'h3 : {dp,cathode} <= 8'b1011_0000;
            4'h4 : {dp,cathode} <= 8'b1001_1001;
            4'h5 : {dp,cathode} <= 8'b1001_0010;
            4'h6 : {dp,cathode} <= 8'b1000_0010;
            4'h7 : {dp,cathode} <= 8'b1111_1000;
            4'h8 : {dp,cathode} <= 8'b1000_0000;
            4'h9 : {dp,cathode} <= 8'b1001_0000;
            4'ha : {dp,cathode} <= 8'b1000_1000;
            4'hb : {dp,cathode} <= 8'b1000_0011;
            4'hc : {dp,cathode} <= 8'b1100_0110;
            4'hd : {dp,cathode} <= 8'b1010_0001;
            4'he : {dp,cathode} <= 8'b1000_0110;
            4'hf : {dp,cathode} <= 8'b1000_1110;
            default : {dp,cathode} <= 8'b1111_1111;
        endcase
    end
end

endmodule