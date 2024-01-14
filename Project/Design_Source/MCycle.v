// The multiplier template is provided, and you should modify it to the improved one and share the hardware resource to implement division.
module MCycle
    #(parameter width = 32) // 32-bits for ARMv3
    (
        input CLK,   // Connect to CPU clock
        input RESET, // Connect to the reset of the ARM processor.
        input Start, // Multi-cycle Enable. The control unit should assert this when MUL or DIV instruction is detected.
        input MCycleOp, // Multi-cycle Operation. "0" for unsigned multiplication, "1" for unsigned division. Generated by Control unit.
        input [width-1:0] Operand1, // Multiplicand / Dividend
        input [width-1:0] Operand2, // Multiplier / Divisor
        output [width-1:0] Result,  //For MUL, assign the lower-32bits result; For DIV, assign the quotient.
        output reg Busy, // Set immediately when Start is set. Cleared when the Results become ready. This bit can be used to stall the processor while multi-cycle operations are on.
        output reg Done
    );

    localparam IDLE = 1'b0;
    localparam COMPUTING = 1'b1;
    reg state, n_state;
    reg Operand1_reg, Operand2_reg;

    // Keep the operands when state is COMPUTING
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            Operand1_reg <= 0;
            Operand2_reg <= 0;
        end
        else begin
            if (state == IDLE) begin
                Operand1_reg <= Operand1;
                Operand2_reg <= Operand2;
            end
            else if (state == COMPUTING) begin
                Operand1_reg <= Operand1_reg;
                Operand2_reg <= Operand2_reg;
            end
        end
    end

    // state machine
    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            state <= IDLE;
        else
            state <= n_state;
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if(Start) begin
                    n_state = COMPUTING;
                    Busy = 1'b1;
                end
                else begin
                    n_state = IDLE;
                    Busy = 1'b0;
                end
            end
            COMPUTING: begin
                if(~Done) begin
                    n_state = COMPUTING;
                    Busy = 1'b1;
                end
                else begin
                    n_state = IDLE;
                    Busy = 1'b0;
                end
            end
        endcase
    end

    reg [5:0] count = 0; // assuming no computation takes more than 64 cycles.
    reg [2*width-1:0] temp_sum = 0;
    reg sign = 0;

    // Multi-cycle Multiplier & divider
    always@(posedge CLK or posedge RESET) begin: COMPUTING_PROCESS // process which does the actual computation
        if(RESET) begin
            count <= 0 ;
            temp_sum <= 0;
            Done <= 0;
            sign <= 0;
        end
        // state: IDLE
        else if(state == IDLE && n_state == COMPUTING) begin
            count <= 0;
            Done <= 0;
            if(~MCycleOp) 
                {sign,temp_sum} <= {1'b0,{width{1'b0}},Operand1_reg};
            else
                {sign,temp_sum} <= ({1'b0,{width{1'b0}},Operand1_reg} << 1) - {1'b0,Operand2_reg,{width{1'b0}}};        
            // else IDLE->IDLE: registers unchanged
        end
        // state: COMPUTING
        else if(n_state == COMPUTING) begin
            if(~MCycleOp) begin // Multiply operation
                if(count == width-1) begin
                    Done <= 1'b1;
                    count <= 0;
                end
                else begin
                    Done <= 1'b0;
                    count <= count + 1;
                end
                if(temp_sum[0])
                    temp_sum <= (temp_sum + {Operand2_reg, {width{1'b0}}}) >> 1;
                else
                    temp_sum <= temp_sum >> 1;
            end
            // Multiplier end
            else begin // Divide operation
                if(count == width-1) begin
                    Done <= 1'b1;
                    count <= 0;
                end
                else begin
                    Done <= 1'b0;
                    count <= count + 1;
                end
                if (!sign) begin // remainder >= 0
                    {sign,temp_sum} <= ({sign,temp_sum} << 1) - {1'b0,Operand2_reg,{width{1'b0}}};
                    temp_sum[0] <= 1'b1;
                end
                else begin // remainder < 0
                    {sign,temp_sum} <= (({sign,temp_sum} + {1'b0,Operand2_reg,{width{1'b0}}}) << 1) - {1'b0,Operand2,{width{1'b0}}};
                    temp_sum[0] <= 1'b0;
                end
            end
        end
        // else COMPUTING->IDLE: registers unchanged
    end

    assign Result = temp_sum[width-1:0];

endmodule

