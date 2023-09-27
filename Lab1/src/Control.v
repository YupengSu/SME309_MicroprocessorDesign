module Control(
    input clk,
    input rst_n,

    input btn_p, // pause button
    input btn_spdup, // speed up button
    input btn_spddn, // speed down button

    output [7:0] addr,
    
    output [7:0] led_data // output addr by led 
);

parameter LOW_SPEED = 3'b001; // 0.25 word/sec
parameter NORM_SPEED = 3'b010; // 1 word/sec
parameter HIGH_SPEED = 3'b100; // 4 word/sec

// ===============================================
//         Button Sampling and Debouncing
// ===============================================

reg [20:0] key_cnt;
reg [2:0] key_scan,key_scan_r,key_flag;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        key_cnt <= 21'd0;
        key_scan <= 3'b111;
    end
    else begin
        if (key_cnt == 21'd1_999_999) begin // 100M/50 - 1 = 1_999_999 (Sampling rate: 20ms = 50Hz)
            key_cnt <= 21'd0;
            key_scan <= {btn_p,btn_spdup,btn_spddn};
        end
        else begin
            key_cnt <= key_cnt + 21'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        key_flag <= 3'b000;
    end
    else begin
        key_flag = (key_scan_r) & (~key_scan);
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        key_scan_r <= 3'b111;
    end
    else begin
        key_scan_r <= key_scan;
    end
end

// ===============================================432343
//           Counter: 400*1000*1000
// ===============================================

reg pause_flag;
reg [9:0] cnt, cnt_k, cnt_m;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        pause_flag <= 1'b0;
    end
    else begin
        if (key_flag[2]) begin
            pause_flag <= ~pause_flag;
        end
        else begin
            pause_flag <= pause_flag;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 10'd0;
    end
    else begin
        if (cnt == 10'd999) begin
            cnt <= 10'd0;
        end
        else if (pause_flag) begin
            cnt <= cnt;
        end
        else begin
            cnt <= cnt + 10'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_k <= 10'd0;
    end
    else begin
        if (cnt_k == 10'd999 && cnt == 10'd999) begin
            cnt_k <= 10'd0;
        end
        else if (cnt == 10'd999) begin
            cnt_k <= cnt_k + 10'd1;
        end
        else begin
            cnt_k <= cnt_k;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_m <= 10'd0;
    end
    else begin
        if (cnt_m == 10'd399 && cnt_k == 10'd999 && cnt == 10'd999) begin
            cnt_m <= 10'd0;
        end
        else if (cnt == 10'd999 && cnt_k == 10'd999) begin
            cnt_m <= cnt_m + 10'd1;
        end
        else begin
            cnt_m <= cnt_m;
        end
    end
end

// ===============================================
//              FSM: Speed Tranfer
// ===============================================

reg [2:0] current_state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= NORM_SPEED;
    end
    else begin
        current_state <= next_state;
    end
end

always @(*) begin
    if (current_state == NORM_SPEED) begin
        if (key_flag[1]) begin
            next_state = HIGH_SPEED;
        end
        else if (key_flag[0]) begin
            next_state = LOW_SPEED;
        end
        else begin
            next_state = NORM_SPEED;
        end
    end
    else if (current_state == HIGH_SPEED) begin
        if (key_flag[0]) begin
            next_state = NORM_SPEED;
        end
        else begin
            next_state = HIGH_SPEED;
        end
    end
    else if (current_state == LOW_SPEED) begin
        if (key_flag[1]) begin
            next_state = NORM_SPEED;
        end
        else begin
            next_state = LOW_SPEED;
        end
    end
    else begin
        next_state = current_state;
    end
end

reg [7:0] addr_r;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr_r <= 8'b00000000;
    end
    else begin
        case (current_state)
            LOW_SPEED: begin
                if (cnt_m % 400 == 399 && cnt_k == 999 && cnt == 999) begin
                    addr_r <= addr_r + 8'b00000001;
                end
                else begin
                    addr_r <= addr_r;
                end
            end
            NORM_SPEED: begin
                if (cnt_m % 100 == 99 && cnt_k == 999 && cnt == 999) begin
                    addr_r <= addr_r + 8'b00000001;
                end
                else begin
                    addr_r <= addr_r;
                end
            end
            HIGH_SPEED: begin
                if (cnt_m % 25 == 24 && cnt_k == 999 && cnt == 999) begin
                    addr_r <= addr_r + 8'b00000001;
                end
                else begin
                    addr_r <= addr_r;
                end
            end
            default: begin
                addr_r <= addr_r;
            end
        endcase
    end
end

assign addr = addr_r;
assign led_data = addr_r;


endmodule