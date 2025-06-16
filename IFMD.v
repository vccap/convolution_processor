module IFMD_ram (
    input wire clk,
    input wire IFMD_write,//=1->寫入, =0->讀出
    input wire IFMD_read,
    input wire [5:0] write_addr, //要寫入/讀出的地址
    input wire [5:0] read_addr, //啟動地址
    input wire [7:0] IFMD_in,
    output reg [7:0] IFMD_out,
    output wire [7:0] debug_mem0,
    output wire [7:0] debug_mem1,
    output wire [7:0] debug_mem2
);
    reg [7:0] IFMD_data [0:63];  
    assign debug_mem0 = IFMD_data[0];
    assign debug_mem1 = IFMD_data[1];
    assign debug_mem2 = IFMD_data[2];
    

    always @(posedge clk) begin
            if(IFMD_write)begin
                IFMD_data[write_addr] <= IFMD_in;//寫入
                $display("RAM write: addr=%0d, data=%0d", write_addr, IFMD_in);
            end            
    end
    always @(posedge clk) begin
        if(IFMD_read)begin
            IFMD_out <= IFMD_data[read_addr];//讀出
            $display("RAM read: addr=%0d, data=%0d", read_addr, IFMD_out);
        end
    end
    //end

endmodule