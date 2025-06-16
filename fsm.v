module fsm(
    input wire clk,
    // input rst_n,
    input wire write_done,
    input wire conv_done,
    input wire start_fsm,
    output reg IFMD_write,
    output reg write_en,
    output reg conv_start,
    output reg fsm_done
);
    localparam IDLE = 2'b00, WRITE = 2'b01, CONV = 2'b10, DONE = 2'b11;
    reg [1:0] state;

    initial begin
        state = IDLE;
        IFMD_write = 0;
        conv_start = 0;
        write_en = 0;
        fsm_done = 0;
    end

    always @(posedge clk) begin
        if(start_fsm) begin
        case (state)
            IDLE: begin
                $display("FSM_Read IFMD");
                IFMD_write <= 1;
                write_en <= 1; // Enable write to IFMD RAM
                state <= WRITE;
            end
            WRITE: begin
                if (write_done) begin
                    write_en <= 0; // Disable write to IFMD RAM
                    $display("FSM_Write Done");
                    IFMD_write <= 0;
                    
                    state <= CONV;
                end else begin
                    write_en <= 1; // Keep writing to IFMD RAM
                    IFMD_write <= 1; // Keep IFMD write enabled

                    $display("FSM_WRITE");
                    state <= WRITE;
                end
            end
            CONV: begin
                if (conv_done) begin
                    state <= DONE;
                    conv_start <= 0; // Disable conv start signal
                    $display("FSM_Conv Done");
                end
                else begin
                    conv_start <= 1;
                    $display("FSM_CONV");
                    state <= CONV;
                end
            end
            DONE: begin
                state <= DONE;
                fsm_done <= 1;
                $display("FSM_Done");

            end
        endcase
        end
    end
endmodule

// module fsm(
//     input clk,
//     input in_st,
//     input IFMD_done,
//     input conv_done,
//     output reg IFMD_read,
//     output reg kernel_read,
//     output reg conv_start,
//     output reg out_st,
//     output reg [2:0] state,
//     output reg wr_in,
//     output reg wr_out
// );
//     //FSM states
//     parameter IDLE = 3'b000;
//     parameter INPUT_RAM = 3'b001;
//     parameter CONV_START = 3'b010;
//     parameter OUTPUT_RAM = 3'b011;

//     reg [2:0] current_state, next_state;

//     always @(posedge clk or negedge in_st) begin
//         if (~in_st) begin
//             current_state <= IDLE;
//         end else begin
//             current_state <= next_state;
//         end
//     end

//     always @(*) begin
//         // Initialize outputs
//         IFMD_start = 0;
//         conv_start = 0;
//         out_st = 0;
//         wr_in = 0;
//         wr_out = 1;

//         case (current_state)
//             IDLE: begin
//                 // To prevent unknown state of reading 0 memory
//                 wr_in = 1;
//                 next_state = INPUT_RAM;
//             end
//             INPUT_RAM: begin
//                 wr_in = 1;
//                 if (IFMD_done) begin
//                     next_state = CONV_START;
//                     IFMD_start = 0;
//                     conv_start = 1;
//                 end else begin
//                     next_state = INPUT_RAM;
//                     IFMD_start = 1;
//                     conv_start = 0;
//                 end
//             end
//             CONV_START: begin
//                 if (conv_done) begin
//                     next_state = OUTPUT_RAM;
//                 end else begin
//                     next_state = CONV_START;
//                 end
//             end
//             OUTPUT_RAM: begin
//                 out_st = 1; // Signal to output RAM that data is ready to be written
//                 wr_out = 1; // Enable write to output RAM
//                 next_state = IDLE; // Go back to IDLE after outputting data
//             end
//             default: begin
//                 next_state = IDLE; // Default case to handle unexpected states
//             end
//         endcase

//         state = current_state; // Update the state output
//     end
// endmodule
