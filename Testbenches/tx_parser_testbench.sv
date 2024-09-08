`timescale 1ns / 1ps


module tx_parser_testbench();

logic clk = 0, reset = 0, tx_serial;
logic [11:0] bcd_temp = 0;  
logic [14*8-1:0] tx_accumulator = '0;

tx_parser dut(clk, reset, bcd_temp, tx_serial);

always
    #5 clk = ~clk;
    
initial
begin

    reset = 1;
    bcd_temp = {4'h2, 4'h3, 4'h7}; // testing for "Temp: 23.7 C\r\n"
    #10
    
    reset = 0;    
    
    while(dut.char_count != 0)
    begin
        @(posedge clk);
       
    // look-up table for tx_accumulator  
    case (dut.char_count)
        4'd15: tx_accumulator[111:104] = dut.tx_byte;
        4'd14: tx_accumulator[103:96]  = dut.tx_byte;
        4'd13: tx_accumulator[95:88]   = dut.tx_byte;
        4'd12: tx_accumulator[87:80]   = dut.tx_byte;
        4'd11: tx_accumulator[79:72]   = dut.tx_byte;
        4'd10: tx_accumulator[71:64]   = dut.tx_byte;
        4'd9:  tx_accumulator[63:56]   = dut.tx_byte;
        4'd8:  tx_accumulator[55:48]   = dut.tx_byte;
        4'd7:  tx_accumulator[47:40]   = dut.tx_byte;
        4'd6:  tx_accumulator[39:32]   = dut.tx_byte;
        4'd5:  tx_accumulator[31:24]   = dut.tx_byte;
        4'd4:  tx_accumulator[23:16]   = dut.tx_byte;
        4'd3:  tx_accumulator[15:8]    = dut.tx_byte;
        4'd2:  tx_accumulator[7:0]     = dut.tx_byte;
        default: ;
    endcase      
            
    end
    
    wait(dut.char_count == 0);
    
    if (tx_accumulator == {"Temp: 23.7 C", 8'h0D, 8'h0A}) // "Temp: 23.7 C\r\n"
    begin
        $display("Sim Passed got Temp: 23.7 C");
    end
    else
    begin
        $display("Sim Failed got %s", tx_accumulator);
    end
    
    
    #10 $finish;

end



endmodule
