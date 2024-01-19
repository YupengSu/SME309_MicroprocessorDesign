module AssociativeCache4Way # (
  // Define your cache parameters
    parameter WAY_NUM = 4,
    parameter ROW_WIDTH = 8,
    parameter TAG_WIDTH = 22,
    parameter ROW = 256,
    parameter FLAG_RST = 256'b0
) (
    input CLK,
    input Reset,

    input Start,                        // from CPU control unit

    input WriteEnable,                  // from CPU instr / STR
    input [31:0] RWAddr,                // from CPU instr / LRD
    input [31:0] WriteData,             // from CPU instr / STR
    output reg [31:0] ReadData,         // to CPU Registers
    output reg WriteReady,              // to CPU control unit
    output reg ReadReady,               // to CPU control unit
    
    input MemReadFinish,                // from data memory
    input MemWriteFinish,               // from data memory
    output reg MemReadStart,            // to data memory
    output reg MemWriteStart,           // to data memory
    output reg [31:0] MemReadAddr,      // to data memory
    input [31:0] MemReadData,           // from data memory
    output reg [31:0] MemWriteAddr,     // to data memory
    output reg [31:0] MemWriteData      // to data memory
);
    
    localparam IDLE = 3'b000;
    localparam READ_CACHE = 3'b001;
    localparam WRITE_CACHE = 3'b010;
    localparam WRITE_BACK = 3'b011;
    localparam READ_MEM = 3'b100;
    localparam WRITE_ALLOCATE = 3'b101;

    reg [2:0] state, n_state;

    reg [ROW_WIDTH-1:0] Datas [0:WAY_NUM-1][0:ROW-1];  // 4-way set associative
    reg [TAG_WIDTH-1:0] Tags [0:WAY_NUM-1][0:ROW-1];
    reg [0:ROW-1] Valids [0:WAY_NUM-1];
    reg [0:ROW-1] Dirtys [0:WAY_NUM-1]; // Write-back
    reg [1:0] Recents [0:ROW-1]; // ensure FIFO replacement

    /* Combinational logic: Find Hit and Data */
    wire[0:WAY_NUM-1] Hits;
    reg [1:0] Idx;
    wire Hit;
    wire [31:0] Data;
    
    genvar i;
    generate
        for (i = 0; i < WAY_NUM; i = i + 1) begin : HIT_ASSIGN
            assign Hits[i] = Valids[i][RWAddr[9:2]] & (RWAddr[31:10] == Tags[i][RWAddr[9:2]]);
        end
    endgenerate

    assign Hit = Hits[0] | Hits[1] | Hits[2] | Hits[3];
    assign Data = Datas[Idx][RWAddr[9:2]];

    always @(*) begin
        case (Hits)
            4'b0001: Idx = 0;
            4'b0010: Idx = 1;
            4'b0100: Idx = 2;
            4'b1000: Idx = 3;
            default: Idx = 0;
        endcase
    end

    /* Sequential logic: Update Valid, Tag, and Data */
    always @(posedge CLK or posedge Reset) begin
        if (Reset)
            state <= IDLE;
        else
            state <= n_state;
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (Start) begin 
                    if (WriteEnable == 1'b0) begin
                        if (Hit)
                            n_state = READ_CACHE;
                        else begin
                            if (Dirtys[Recents[RWAddr[9:2]]][RWAddr[9:2]])
                                n_state = WRITE_BACK;
                            else
                                n_state = READ_MEM;
                        end
                    end
                    else begin
                        if (Hit == 1'b1)
                            n_state = WRITE_CACHE;
                        else begin
                            if (Dirtys[Recents[RWAddr[9:2]]][RWAddr[9:2]])
                                n_state = WRITE_BACK;
                            else
                                n_state = READ_MEM;
                        end
                    end
                end
                else begin
                    n_state = IDLE;
                end
            end
            READ_CACHE: begin
                if (ReadReady) begin
                    n_state = IDLE;
                end
                else begin
                    n_state = READ_CACHE;
                end
            end
            WRITE_CACHE: begin
                if (WriteReady) begin
                    n_state = IDLE;
                end
                else begin
                    n_state = WRITE_CACHE;
                end
            end
            WRITE_BACK: begin
                if (MemWriteFinish) begin
                    n_state = READ_MEM;
                end
                else begin
                    n_state = WRITE_BACK;
                end
            end
            READ_MEM: begin
                if (MemReadFinish) begin
                    n_state = WRITE_ALLOCATE;
                end
                else begin
                    n_state = READ_MEM;
                end
            end
            WRITE_ALLOCATE: begin
                if (WriteEnable == 1'b0) begin
                    n_state = READ_CACHE;
                end
                else begin
                    n_state = WRITE_CACHE;
                end
            end
            default: n_state = IDLE;
        endcase
    end

    always @(posedge CLK or posedge Reset) begin
        if (Reset) begin
            Valids[0] <= FLAG_RST; // reset valid flags
            Valids[1] <= FLAG_RST;
            Valids[2] <= FLAG_RST;
            Valids[3] <= FLAG_RST;
            Dirtys[0] <= FLAG_RST; // reset dirty flags
            Dirtys[1] <= FLAG_RST;
            Dirtys[2] <= FLAG_RST;
            Dirtys[3] <= FLAG_RST;

            // control signal
            WriteReady <= 1'b0;
            ReadReady <= 1'b0;
            MemReadStart <= 1'b0;
            MemWriteStart <= 1'b0;

            // data signal
            ReadData <= 32'b0;
            MemReadAddr <= 32'b0;
            MemWriteAddr <= 32'b0;
            MemWriteData <= 32'b0;
        end 
        else begin
            case (state)
                IDLE: begin
                    WriteReady <= 1'b0;
                    ReadReady <= 1'b0;

                    MemReadStart <= 1'b0;
                    MemWriteStart <= 1'b0;
                end
                READ_CACHE: begin
                    // do nothing
                    ReadReady <= 1'b1;
                    ReadData <= Data;
                end
                WRITE_CACHE: begin
                    // change cache, symbolize dirty
                    WriteReady <= 1'b1;
                    Datas[Idx][RWAddr[9:2]] <= WriteData;
                    Dirtys[Idx][RWAddr[9:2]] <= 1'b1;
                end
                WRITE_BACK: begin
                    // write back
                    MemWriteStart <= 1'b1;
                    MemWriteAddr <= {Tags[Recents[RWAddr[9:2]]][RWAddr[9:2]], RWAddr[9:2], 2'b00};
                    MemWriteData <= Datas[Recents[RWAddr[9:2]]][RWAddr[9:2]];
                end
                READ_MEM: begin
                    // read from memory
                    MemReadStart <= 1'b1;
                    MemReadAddr <= RWAddr;
                end
                WRITE_ALLOCATE: begin
                    // write allocate
                    Datas[Recents[RWAddr[9:2]]][RWAddr[9:2]] <= MemReadData;
                    Tags[Recents[RWAddr[9:2]]][RWAddr[9:2]] <= RWAddr[31:10];
                    Valids[Recents[RWAddr[9:2]]][RWAddr[9:2]] <= 1'b1;
                    Recents[RWAddr[9:2]] <= Recents[RWAddr[9:2]] + 1'b1;
                end
                default: begin
                    WriteReady <= 1'b0;
                    ReadReady <= 1'b0;

                    MemReadStart <= 1'b0;
                    MemWriteStart <= 1'b0;
                end
            endcase
        end
            
    end

endmodule
