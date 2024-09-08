`timescale 1ns / 1ps

module double_dabble_fraction
(
    input logic [15:0] frac_scaled,
    output logic [3:0] bcd_out_o
);
    logic [19:0] bcd_out;
    logic loop_done = 0;
    
    always_comb
    begin
        bcd_out = 0;
        for (int i = 0; i < 16; i++)
        begin
            bcd_out = {bcd_out[18:0], frac_scaled[15-i]};  // Shift in the next bit
            
            // Check and correct each 4-bit segment if greater than 4
            if (i < 15 && bcd_out[3:0] > 4)
                bcd_out[3:0] = bcd_out[3:0] + 3;
                
            if (i < 15 && bcd_out[7:4] > 4)
                bcd_out[7:4] = bcd_out[7:4] + 3;        
            
            if (i < 15 && bcd_out[11:8] > 4)
                bcd_out[11:8] = bcd_out[11:8] + 3;
                
            if (i < 15 && bcd_out[15:12] > 4)
                bcd_out[15:12] = bcd_out[15:12] + 3;
                
            if (i < 15 && bcd_out[19:16] > 4)
                bcd_out[19:16] = bcd_out[19:16] + 3;
                
            if(i == 15)
            begin
            
                if(bcd_out[19:16] != 0)
                    bcd_out_o = bcd_out[19:16];
                else if(bcd_out[15:12] != 0)
                    bcd_out_o = bcd_out[15:12];
                else if (bcd_out[11:8] != 0)
                    bcd_out_o = bcd_out[11:8];
                else if (bcd_out[7:4] != 0)
                    bcd_out_o = bcd_out[7:4];
                else if (bcd_out[3:0] != 0)
                    bcd_out_o = bcd_out[3:0];
                else
                    bcd_out_o = 0;           
            end
            else
                bcd_out_o = 0;
                        
        end

    end
    
    

endmodule
