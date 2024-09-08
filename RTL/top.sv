`timescale 1ns / 1ps

module top
(
    input wire clk, reset,
    inout tri TMP_SCL, TMP_SDA, TMP_INT, TMP_CT,
    output wire [12:0] LED,
    output wire tx_serial
    
);

    logic [11:0] bcd_temp;

    adt7420_i2c i2c(.*);
    
    tx_parser tx(.*);
    

endmodule
