`timescale 1ns / 1ps


module double_dabble_testbench();

    logic [7:0] num_in, bcd_out_o;
    
    double_dabble dut(.*);
    
    initial
    begin
        num_in = 8'd23;
        #10
        
        if(bcd_out_o == 8'h23)
            $display("Sim Passed for num_in = 23");
        else
            $display("Sim failed for num_in = 23, got %d", num_in);
            
        #10
        
        num_in = 8'd17;     

        #10
        
        if(bcd_out_o == 8'h17)
            $display("Sim Passed for num_in = 17");
        else
            $display("Sim failed for num_in = 17, got %d", num_in);
       
    end
