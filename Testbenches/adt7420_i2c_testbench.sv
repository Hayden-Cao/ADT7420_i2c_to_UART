`timescale 1ns / 10ps

module adt7420_i2c_testbench();

    logic clk = 0;
    tri TMP_SCL, TMP_SDA, TMP_INT, TMP_CT;
    logic [12:0] LED;
    logic [11:0] bcd_temp;
    
    
    // enum from i2c_driver for state names in sim
    enum bit [2:0] {IDLE, START, TIME_LOW, TIME_SETUP, TIME_HIGH, TIME_HOLD, TIME_STOP} i2c_states;
    
    adt7420_i2c dut(.*);
    
    always
    begin
        i2c_states = dut.i2c_states;
        #5 clk = ~clk;  
    end


endmodule
