`ifndef _BCD_PKG
`define _BCD_PKG

package binary_to_bcd_func;
   
    function bit [7:0] bin_to_bcd;
    
    input[31:0] binary_in;  
    input int_or_frac; // int = 1, frac = 0
    logic [31:0] bcd_out;
    
    for(int i = 0; i < 32; i++)
    begin
        bcd_out = {bcd_out[30:0], binary_in[31-i]};
        
        if(i < 31 && bcd_out[3:0] > 4)
            bcd_out[3:0] = bcd_out + 3;
        
        if(i < 31 && bcd_out[7:4] > 4)
            bcd_out[7:4] = bcd_out + 3;        

        if(i < 31 && bcd_out[11:8] > 4)
            bcd_out[11:8] = bcd_out + 1;
        
        if(i < 31 && bcd_out[15:12] > 4)
            bcd_out[15:12] = bcd_out + 3;

        if(i < 31 && bcd_out[19:16] > 4)
            bcd_out[19:16] = bcd_out + 3;

        if(i < 31 && bcd_out[23:20] > 4)
            bcd_out[23:20] = bcd_out + 3;

        if(i < 31 && bcd_out[27:24] > 4)
            bcd_out[27:24] = bcd_out + 3;
            
        if(i < 31 && bcd_out[31:28] > 4)
            bcd_out[31:28] = bcd_out + 3;

    end
    
    if(int_or_frac)
    begin
        return bcd_out[7:0];
    end
    else
    begin
        
        for(int i = 28; i >= 0; i -= 4)
        begin
            if(bcd_out[i +:4] != 4'b0000)
            begin
                if(i <= 24)
                begin
                    return bcd_out[i -: 8];
                end
                else
                begin
                    return {bcd_out[31:28], 4'b0000};
                end
            end
            
        end
        
    end
    
                
    endfunction


endpackage

`endif
