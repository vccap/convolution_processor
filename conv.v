`include "IFMD_ram.v"
module conv(
    input wire clk,
    input wire conv_start,

    input wire [7:0] IFMD_out,
    output reg IFMD_read,
    output reg [5:0] read_addr,

    //output reg[15:0] OFMD_in,
    output reg [5:0]OFMD_addr,
    output reg conv_done
);

    //mac
    reg [15:0] mult [0:8];
    //reg [15:0] result [0:35];
    reg [13:0] mult8_reg;
    reg [15:0] sum1 [0:3];
    reg [15:0] total_sum;
    // 3x3 window output
    reg [7:0] win_data0, win_data1, win_data2;
    reg [7:0] win_data3, win_data4, win_data5;
    reg [7:0] win_data6, win_data7, win_data8;

    reg [7:0] OFMD_in [0:63];  // 記憶體陣列形式


    reg [7:0] kernel [0:8];

    initial begin
            kernel[0] = 8'h01;  kernel[1] = 8'h02;  kernel[2] = 8'h03;
            kernel[3] = 8'h04;  kernel[4] = 8'h05;  kernel[5] = 8'h06;
            kernel[6] = 8'h07;  kernel[7] = 8'h08;  kernel[8] = 8'h09;
    end
    //convolution 
    reg [2:0] x, y;
    reg [5:0] state;

    localparam
        IDLE    = 0,
        LOAD0   = 1,  WAIT0   = 2,
        LOAD1   = 3,  WAIT1   = 4,
        LOAD2   = 5,  WAIT2   = 6,
        LOAD3   = 7,  WAIT3   = 8,
        LOAD4   = 9,  WAIT4   = 10,
        LOAD5   = 11, WAIT5   = 12,
        LOAD6   = 13, WAIT6   = 14,
        LOAD7   = 15, WAIT7   = 16,
        LOAD8   = 17, WAIT8   = 18,
        READ0   = 19, READ1   = 20,
        READ2   = 21, READ3   = 22,
        READ4   = 23, READ5   = 24,
        READ6   = 25, READ7   = 26,
        READ8   = 27,
        NEXT        = 28,
        MAC_STAGE1  = 29,
        MAC_STAGE2  = 30,
        MAC_STAGE3  = 31,
        MAC_WRITE   = 32;

    wire [5:0] win_add [0:8];
    assign win_add[0] = (y+0)*8 + (x+0);
    assign win_add[1] = (y+0)*8 + (x+1);
    assign win_add[2] = (y+0)*8 + (x+2);
    assign win_add[3] = (y+1)*8 + (x+0);
    assign win_add[4] = (y+1)*8 + (x+1);
    assign win_add[5] = (y+1)*8 + (x+2);
    assign win_add[6] = (y+2)*8 + (x+0);
    assign win_add[7] = (y+2)*8 + (x+1);
    assign win_add[8] = (y+2)*8 + (x+2);

    reg [6:0]count = 0;

    // === Initialization for state, x, y, conv_done, IFMD_addr_en, IFMD_wr_en, count ===
    initial begin
        x = 0;
        y = 0;
        state = IDLE;
        conv_done = 0;
        IFMD_read = 0;
        OFMD_addr = 0;
        count = 0;
    end

    always @(posedge clk) begin//    always @(posedge clk or posedge rst) begin
        if(conv_start) begin
            case (state)
                IDLE: begin
                    $display("Conv_IDLE");
                    if(!conv_done)begin
                        state <= LOAD0;
                        end else begin
                            $display("Conv already done");
                        end
                end

                LOAD0: begin
                    $display("Cycle %d start", y);
                    IFMD_read <= 1;
                    read_addr <= win_add[0];
                    state <= WAIT0;
                end
                WAIT0: begin
                    IFMD_read <= 0;
                    state <= READ0;
                end
                READ0: begin
                    win_data0 <= IFMD_out;
                    state <= LOAD1;
                end

                LOAD1: begin
                    IFMD_read <= 1;
                    read_addr <= win_add[1];
                    state <= WAIT1;
                end
                WAIT1: begin
                    IFMD_read <= 0;
                    state <= READ1;
                end
                READ1: begin
                    win_data1 <= IFMD_out;
                    state <= LOAD2;
                end

                LOAD2: begin
                    IFMD_read <= 1;
                    read_addr <= win_add[2];
                    state <= WAIT2;
                end
                WAIT2: begin
                    IFMD_read <= 0;
                    state <= READ2;
                end
                READ2: begin
                    win_data2 <= IFMD_out;
                    state <= LOAD3;
                end

                LOAD3: begin
                    IFMD_read <= 1;
                    read_addr <= win_add[3];
                    state <= WAIT3;
                end
                WAIT3: begin
                    IFMD_read <= 0;
                    state <= READ3;
                end
                READ3: begin
                    win_data3 <= IFMD_out;
                    state <= LOAD4;
                end

                LOAD4: begin
                    IFMD_read <= 1;
                    read_addr <= win_add[4];
                    state <= WAIT4;
                end
                WAIT4: begin
                    IFMD_read <= 0;
                    state <= READ4;
                end
                READ4: begin
                    win_data4 <= IFMD_out;
                    state <= LOAD5;
                end

                LOAD5: begin
                    IFMD_read <= 1;
                    read_addr <= win_add[5];
                    state <= WAIT5;
                end
                WAIT5: begin
                    IFMD_read <= 0;
                    state <= READ5;
                end
                READ5: begin
                    win_data5 <= IFMD_out;
                    state <= LOAD6;
                end

                LOAD6: begin
                    IFMD_read <= 1;
                    read_addr <= win_add[6];
                    state <= WAIT6;
                end
                WAIT6: begin
                    IFMD_read <= 0;
                    state <= READ6;
                end
                READ6: begin
                    win_data6 <= IFMD_out;
                    state <= LOAD7;
                end

                LOAD7: begin
                    IFMD_read <= 1;
                    read_addr <= win_add[7];
                    state <= WAIT7;
                end
                WAIT7: begin
                    IFMD_read <= 0;
                    state <= READ7;
                end
                READ7: begin
                    win_data7 <= IFMD_out;
                    state <= LOAD8;
                end

                LOAD8: begin
                    IFMD_read <= 1;
                    read_addr <= win_add[8];
                    state <= WAIT8;
                end
                WAIT8: begin
                    IFMD_read <= 0;
                    state <= READ8;
                end
                READ8: begin
                    win_data8 <= IFMD_out;
                    $display("Cycle %d done", y);
                    state <= NEXT;
                end

                NEXT: begin
                        if (x == 5) begin
                            x <= 0;
                            y <= y + 1;
                        end else begin
                            x <= x + 1;
                        end
                        state <= MAC_STAGE1;
                        
                    end
                

                MAC_STAGE1: begin
                    $display("Mac Stage 1...position%d", count);
                    mult[0] <= win_data0 * kernel[0];
                    mult[1] <= win_data1 * kernel[1];
                    mult[2] <= win_data2 * kernel[2];
                    mult[3] <= win_data3 * kernel[3];
                    mult[4] <= win_data4 * kernel[4];
                    mult[5] <= win_data5 * kernel[5];
                    mult[6] <= win_data6 * kernel[6];
                    mult[7] <= win_data7 * kernel[7];
                    mult[8] <= win_data8 * kernel[8];
                    state <= MAC_STAGE2;  
                end

                MAC_STAGE2: begin
                    sum1[0] <= mult[0] + mult[1];
                    sum1[1] <= mult[2] + mult[3];
                    sum1[2] <= mult[4] + mult[5];
                    sum1[3] <= mult[6] + mult[7];
                    mult8_reg <= mult[8];
                    state <= MAC_STAGE3;
                end

                MAC_STAGE3: begin
                    total_sum <= (sum1[0] + sum1[1]) + (sum1[2] + sum1[3]) + mult8_reg;
                    state <= MAC_WRITE;
                end
                
                MAC_WRITE: begin
                    if (count == 36) begin//x == 5 && y == 5
                        conv_done <= 1;
                        state <= IDLE;
                    end else begin
                    OFMD_addr <= count;
                    OFMD_in[count] <= total_sum;  // or OFMD_in[count] if using array
                    $display("Result[%d] = %d", count, total_sum);
                    count <= count + 1;
                    state <= LOAD0;
                    end
                end
    
            endcase
        end
    end
    // end

    wire [5:0] win_add0_dbg = win_add[0];
    wire [5:0] win_add1_dbg = win_add[1];
    wire [5:0] win_add2_dbg = win_add[2];
    wire [5:0] win_add3_dbg = win_add[3];
    wire [5:0] win_add4_dbg = win_add[4];
    wire [5:0] win_add5_dbg = win_add[5];
    wire [5:0] win_add6_dbg = win_add[6];
    wire [5:0] win_add7_dbg = win_add[7];
    wire [5:0] win_add8_dbg = win_add[8];

endmodule
