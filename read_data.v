module read_data (
    input wire clk,
    input wire write_en,
    output reg write_done,
    output reg IFMD_write,
    output reg [5:0] write_addr,
    output reg [7:0] IFMD_in
);
    reg [7:0] IFMD_data [0:63];
    reg [1:0] write_state = 0;
    reg [6:0] count;

    localparam IDLE = 0, WRITE = 1, DONE = 2;

    initial begin
        $readmemb("TM/IFMD_DATA.mem", IFMD_data);
        count <= 0;
        write_done <= 0;
        write_addr = 0;
        IFMD_in = 0;
    end

    always @(posedge clk) begin
        case (write_state)
            IDLE: begin
                if (write_en) begin
                    $display("to WRITE");
                    write_state <= WRITE;
                end
            end
            WRITE: begin
                if (count == 64) begin
                    write_done <= 1;
                    $display("write_done = %d", write_done);                    
                    $display("write_DONE!!!!!");
                    write_state <= DONE;
                end else begin
                    $display("Write_ Writing");
                    IFMD_write <= 1;
                    write_addr <= count;
                    IFMD_in <= IFMD_data[count];
                    $display("Data input... %d = %d", count, IFMD_data[write_addr]);
                    count <= count + 1;
                    write_state <= WRITE;
                end
                
                
            end
            DONE: begin    
                IFMD_write <= 0;
                write_state <= IDLE;                
            end
        endcase
    end
endmodule
