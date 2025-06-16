`timescale 1ns/1ns
`include "fsm.v"
`include "read_data.v"
`include "conv.v"

module tb_conv;
    reg clk = 0;
    wire [7:0] IFMD_in, IFMD_out;
    wire read_done, IFMD_read, IFMD_write;
    wire write_done;
    wire conv_start, conv_done;
    wire fsm_done;
    reg start_fsm;

    wire [5:0] read_addr, write_addr;
    wire write_en;

    // clock
    always #10 clk = ~clk;

    //IFMD_ram
    IFMD_ram IFMD_ram(
        .clk(clk),
        .IFMD_write(IFMD_write),            
        .IFMD_read(IFMD_read),
        .read_addr(read_addr),
        .write_addr(write_addr),
        .IFMD_in(IFMD_in),
        .IFMD_out(IFMD_out),
        .debug_mem0(),
        .debug_mem1(),
        .debug_mem2()
    );

    // FSM
    fsm fsm(
        .clk(clk),
        .start_fsm(start_fsm),
        .write_done(write_done),
        .conv_done(conv_done),
        .write_en(write_en),
        .IFMD_write(IFMD_write),
        .conv_start(conv_start),
        .fsm_done(fsm_done) 
    );

    // read_data
    read_data read_data(
        .clk(clk),
        .write_en(write_en),
        .write_done(write_done),
        .IFMD_write(IFMD_write),
        .write_addr(write_addr),
        .IFMD_in(IFMD_in)
    );

    // conv
    conv conv(
        .clk(clk),
        .conv_start(conv_start),
        .conv_done(conv_done),
        .IFMD_read(IFMD_read),
        .read_addr(read_addr),
        .IFMD_out(IFMD_out),
        //.OFMD_in(),
        .OFMD_addr()
    );

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, tb_conv);
    end

    initial begin
        $display("=== Start Test ===");
        start_fsm = 1; 

        wait(fsm_done);
        #10;
        $display("=== Test Finished ===");
        start_fsm = 0; // Signal that the FSM is done
        $finish;
        
    end
endmodule
