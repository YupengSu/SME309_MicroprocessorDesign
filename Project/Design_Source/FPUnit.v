`define IDLE 4'b0000
`define CHECK 4'b1111
`define FADD_CHECK 4'b0001
`define FADD_MATCH 4'b0010
`define FADD_CALCULATE 4'b0011
`define FADD_NORMAL 4'b0100
`define FADD_LOOP 4'b0101

`define FMUL_CHECK 4'b1001
`define FMUL_CALCULATE 4'b1010
`define FMUL_NORMAL 4'b1011

module FPUnit #(
    parameter width = 32
)  // 32-bits for ARMv3
(
    input                  CLK,          // Connect to CPU clock
    input                  RESET,        // Connect to the reset of the ARM processor.
    input                  FP_Start,     // Multi-cycle Enable. The control unit should assert this when FADD or FMUL instruction is detected.
    input                  FPUnitOp,     // Multi-cycle Operation. "0" for Single Float Addition, "1" for Single Float Multiplication. Generated by Control unit.
    input      [width-1:0] FP_Operand1_in,
    input      [width-1:0] FP_Operand2_in,
    output     [width-1:0] Result,
    output reg             FP_Busy,      // Set immediately when FP_Start is set. Cleared when the Results become ready. This bit can be used to stall the processor while multi-cycle operations are on.
    output reg             FP_Done
);

    // reg for FP_Operand1_in and FP_Operand2_in
    reg      [width-1:0] FP_Operand1;
    reg      [width-1:0] FP_Operand2;

    reg s3;
    reg [8:0] e3;
    reg [47:0] m3;
    assign Result = {s3, e3[7:0], m3[22:0]};

    wire s1, s2;
    wire [7:0] e1, e2;
    wire [22:0] m1, m2;
    reg [23:0] temp1, temp2;
    assign {s1, e1, m1} = FP_Operand1;
    assign {s2, e2, m2} = FP_Operand2;

    wire nan1, nan2, infinite1, infinite2;
    assign nan1 = (e1 == 8'b1111_1111) & (m1 != 23'b0);
    assign nan2 = (e2 == 8'b1111_1111) & (m2 != 23'b0);
    assign infinite1 = (e1 == 8'b1111_1111) & (m1 == 23'b0);
    assign infinite2 = (e2 == 8'b1111_1111) & (m2 == 23'b0);

    reg [4:0] state;

    // Keep the operands when state is COMPUTING
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            FP_Operand1 <= 0;
            FP_Operand1 <= 0;
        end
        else begin
            if (state == `IDLE) begin
                FP_Operand1 <= FP_Operand1_in;
                FP_Operand2 <= FP_Operand2_in;
            end
            else begin
                FP_Operand1 <= FP_Operand1;
                FP_Operand1 <= FP_Operand1;
            end
        end
    end

    // state machine
    // always @(posedge CLK or posedge RESET) begin
    //     if () 
    //         state <= `IDLE;
    //     else 
    //         state <= state;
    // end

    // always @(*) begin
    //     case (state)
    //         `IDLE: begin
    //             if (FP_Start) begin
    //                 n_state = `CHECK;
    //                 FP_Busy = 1'b1;
    //             end 
    //             else begin
    //                 n_state = `IDLE;
    //                 FP_Busy = 1'b0;
    //             end
    //         end
    //         default: begin
    //             if (~FP_Done) begin
    //                 n_state = state;
    //                 FP_Busy = 1'b1;
    //             end 
    //             else begin
    //                 n_state = `IDLE;
    //                 FP_Busy = 1'b0;
    //             end
    //         end
    //     endcase
    // end

    // Multi-cycle 
    always @(posedge CLK or posedge RESET) begin : COMPUTING_PROCESS  // process which does the actual computation
        if (RESET) begin
            FP_Done <= 1'b0;
            state <= `IDLE;
            {s3, e3, m3} <= 'b0;
            temp1 <= 24'b0;
            temp2 <= 24'b0;
            FP_Busy <= 1'b0;
        end 
        else begin
            case (state)
                `IDLE: begin
                    FP_Done <= 1'b0;
                    state <= `IDLE;
                    temp1 <= 24'b0;
                    temp2 <= 24'b0;
                    if (FP_Start) begin
                        state <= `CHECK;
                        FP_Busy <= 1'b1;
                    end 
                    else begin
                        state <= `IDLE;
                        FP_Busy <= 1'b0;
                end
                end
                `CHECK: begin
                    case ({nan1, nan2})
                        2'b00: begin
                            if (infinite1) begin
                                {s3, e3[7:0], m3[22:0]} <= FP_Operand1;
                                state <= `IDLE;
                                FP_Done <= 1'b1;
                                FP_Busy <= 1'b0;
                            end
                            else if (infinite2) begin
                                {s3, e3[7:0], m3[22:0]} <= FP_Operand2;
                                state <= `IDLE;
                                FP_Done <= 1'b1;
                                FP_Busy <= 1'b0;
                            end
                            else begin
                                if (!FPUnitOp) begin
                                    if ({e1, m1} == 22'b0) begin
                                        {s3, e3[7:0], m3[22:0]} <= FP_Operand2;
                                        state <= `IDLE;
                                        FP_Done <= 1'b1;
                                        FP_Busy <= 1'b0;
                                    end
                                    else if ({e2, m2} == 22'b0) begin
                                        {s3, e3[7:0], m3[22:0]} <= FP_Operand1;
                                        state <= `IDLE;
                                        FP_Done <= 1'b1;
                                        FP_Busy <= 1'b0;
                                    end
                                    else begin
                                        state <= `FADD_MATCH;
                                    end
                                end
                                else begin
                                    if (({e1, m1} == 22'b0) | ({e2, m2} == 22'b0)) begin
                                        {s3, e3[7:0], m3[22:0]} <= 32'b0;
                                        state <= `IDLE;
                                        FP_Done <= 1'b1;
                                        FP_Busy <= 1'b0;
                                    end
                                    else begin
                                        state <= `FMUL_CALCULATE;
                                    end
                                end
                            end
                        end
                        2'b01: begin
                            {s3, e3[7:0], m3[22:0]} <= {s2, e2, 1'b1, m2[21:0]};
                            state <= `IDLE;
                            FP_Done <= 1'b1;
                            FP_Busy <= 1'b0;
                        end
                        2'b10: begin
                            {s3, e3[7:0], m3[22:0]} <= {s1, e1, 1'b1, m1[21:0]};
                            state <= `IDLE;
                            FP_Done <= 1'b1;
                            FP_Busy <= 1'b0;
                        end
                        2'b11: begin
                            if ((m1[22]) | (!m2[22])) begin
                                {s3, e3[7:0], m3[22:0]} <= {s2, e2, 1'b1, m2[21:0]};
                            end 
                            else begin
                                {s3, e3[7:0], m3[22:0]} <= {s1, e1, 1'b1, m1[21:0]};
                            end
                            state <= `IDLE;
                            FP_Done <= 1'b1;
                            FP_Busy <= 1'b0;
                        end
                        default: begin
                            {s3, e3[7:0], m3[22:0]} <= 32'bx;
                            state <= 4'bx;
                            state <= `IDLE;
                            FP_Done <= 1'bx;
                            FP_Busy <= 1'bx;
                        end
                    endcase
                end
                `FADD_MATCH: begin
                    if (e1 >= e2) begin
                        if (e1 - e2 >= 8'd23) begin
                            {s3, e3[7:0], m3[22:0]} <= FP_Operand1;
                            state <= `IDLE;
                            FP_Done <= 1'b1;
                            FP_Busy <= 1'b0;
                        end
                        else begin
                            temp1 <= {1'b1, m1};
                            temp2 <= ({1'b1, m2} >> (e1 - e2));
                            e3 <= e1;
                            state <= `FADD_CALCULATE;
                        end
                    end
                    else begin
                        if (e2 - e1 >= 8'd23) begin
                            {s3, e3[7:0], m3[22:0]} <= FP_Operand2;
                            state <= `IDLE;
                            FP_Done <= 1'b1;
                            FP_Busy <= 1'b0;
                        end
                        else begin
                            temp1 <= ({1'b1, m1} >> (e2 - e1));
                            temp2 <= {1'b1, m2};
                            e3 <= e2;
                            state <= `FADD_CALCULATE;
                        end
                    end
                end
                `FADD_CALCULATE: begin
                    if (s1 ^~ s2) begin
                        m3 <= temp1 + temp2;
                        state <= `FADD_NORMAL;
                    end
                    else begin
                        if (temp1 > temp2) begin
                            m3 <= temp1 - temp2;
                            state <= `FADD_NORMAL;
                        end
                        else if (temp1 < temp2) begin
                            m3 <= temp2 - temp1;
                            state <= `FADD_NORMAL;
                        end
                        else begin
                            {s3, e3, m3[22:0]} <= 32'b0;
                            state <= `IDLE;
                            FP_Done <= 1'b1;
                            FP_Busy <= 1'b0;
                        end
                    end
                end
                `FADD_NORMAL: begin
                    if (s1 ~^ s2) begin
                        if (m3[24]) begin
                            e3 <= e3 + 9'b1;
                            s3 <= s1;
                            m3[22:0] <= m3[23:1];
                        end
                        else begin
                            e3 <= e3;
                            s3 <= s1;
                            m3[22:0] <= m3[22:0];
                        end
                        state <= `IDLE;
                        FP_Done <= 1'b1;
                        FP_Busy <= 1'b0;
                    end
                    else begin
                        if (temp1 >= temp2) begin
                            s3 <= s1;
                        end
                        else begin
                            s3 <= s2;
                        end
                        e3 <= e3;
                        state <= `FADD_LOOP;
                    end
                end
                `FADD_LOOP: begin
                    if (!m3[23]) begin
                        if (e3 == 9'b0) begin
                            state <= `IDLE;
                            FP_Done <= 1'b1;
                            FP_Busy <= 1'b0;
                        end
                        else begin
                            e3 <= e3 - 9'b1;
                            m3 <= m3 << 1;
                            state <= `FADD_LOOP;
                        end
                    end
                    else begin
                        // m3 <= m3[22:0];
                        state <= `IDLE;
                        FP_Done <= 1'b1;
                        FP_Busy <= 1'b0;
                    end
                end
                `FMUL_CALCULATE: begin
                    e3 <= e1 + e2 - 9'd127;
                    m3 <= {1'b1, m1} * {1'b1, m2};
                    s3 <= (s1 ^ s2);
                    state <= `FMUL_NORMAL;
                end
                `FMUL_NORMAL: begin
                    if (e3 > 9'd255) begin
                        e3 <= 9'd255;
                        m3[22:0] <= 23'h7fffff;
                    end
                    else if (m3[47]) begin
                        e3 <= e3 + 9'b1;
                        m3[22:0] <= m3[46:24];
                    end
                    else begin
                        m3[22:0] <= m3[45:23];
                    end
                    state <= `IDLE;
                    FP_Done <= 1'b1;
                    FP_Busy <= 1'b0;
                end
                default: begin
                    state <= `IDLE;
                    FP_Done <= 1'b0;
                    FP_Busy <= 1'b0;
                end
            endcase
        end
    end

endmodule
