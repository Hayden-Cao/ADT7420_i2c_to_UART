`timescale 1ns / 1ps

module double_dabble_fraction_testbench();

    logic [15:0] frac_scaled;
    logic [3:0] frac_bcd;
    
    logic [19:0] bcd_internal;
    
    double_dabble_fraction dut(frac_scaled, frac_bcd);
    
    initial
    begin
    
        frac_scaled = 16'd7500;
        
        #25
        bcd_internal = dut.bcd_out;
        if(frac_bcd == 4'd7)
            $display("Sim Passed for 7500");
        else
            $display("Sim Failed for 7500 got %d", frac_bcd);
            
        #25
        
        frac_scaled = 16'd5000;
        
        #25
        bcd_internal = dut.bcd_out;
        if(frac_bcd == 4'd5)
            $display("Sim Passed for 5000");
        else
            $display("Sim Failed for 5000 got %d", frac_bcd);
            
        #10 $finish;
    
    end
    

endmodule
