`timescale 1ns / 1ps

module tx_parser
#(parameter NUM_BITS = 8)
(
    input wire clk,
    input wire reset,
    input logic [11:0] bcd_temp,
    output logic tx_serial
);
    logic data_valid;
    logic [NUM_BITS-1:0] tx_byte;

    logic [11:0] old_values = 0;
    logic prev_tx_ready = 0;
    logic tx_ready;
    
    logic [3:0] char_count = 15;
    
    always_comb
    begin           
        //character lookup table 
        case(char_count)
            15: tx_byte = 8'h54;                        // T
            14: tx_byte = 8'h65;                        // e
            13: tx_byte = 8'h6d;                        // m
            12: tx_byte = 8'h70;                        // p
            11: tx_byte = 8'h3A;                        // :
            10: tx_byte = 8'h20;                        // space
            9:  tx_byte = 8'h30 + bcd_temp[11:8];       // tens place
            8:  tx_byte = 8'h30 + bcd_temp[7:4];        // ones place
            7:  tx_byte = 8'h2E;                        // decimal point 
            6:  tx_byte = 8'h30 + bcd_temp[3:0];        // tenths place
            5:  tx_byte = 8'h20;                        // space
            4:  tx_byte = 8'h43;                        // C
            3:  tx_byte = 8'h0D;                        // carriage return
            2:  tx_byte = 8'h0A;                        // line feed    
            default: tx_byte = 0;
        endcase
    end
    
    always_ff@(posedge clk, posedge reset)
    begin
        
        if(reset)
        begin
            char_count <= 15;
            prev_tx_ready <= tx_ready;
        end
        else
        begin
        
            if((char_count != 0) && (~tx_ready && prev_tx_ready))
                char_count <= char_count - 1;
                
            if((char_count == 0) && (old_values != bcd_temp))
                char_count <= 15;    
                        
            old_values <= bcd_temp;
            prev_tx_ready <= tx_ready;
                
        end
        
    end
    
    assign data_valid = (tx_ready && (char_count != 0));
    
    uart_tx tx(clk, reset, tx_byte, data_valid, tx_serial, tx_ready);

endmodule
