`timescale 1ns / 1ps

/* Code inspired by the I2C design found in the textbook
    FPGA Programming for Begineers by Frank Bruno        */

module adt7420_i2c
#(parameter MASTER_CLK_FREQ = 100_000_000, parameter CLK_PERIOD = 10 /*10 ns period*/)
(
    input wire clk,
    inout tri TMP_SCL, TMP_SDA, TMP_INT, TMP_CT, // names from Nexys A7 xdc file
    output logic [12:0] LED,
    output logic [11:0] bcd_temp
);

    localparam ADT7420_ADDR = 7'b1001011; // 0x4B
    localparam write_bit    = 1'b0;
    localparam ack_bit      = 1'b0;
    localparam read_bit     = 1'b1;
    
    // Minimum timing data found in ADT7420 Data Sheet
    localparam TIME_1SEC   = int'(MASTER_CLK_FREQ);        // Clock ticks in 1 sec can set to lower value to testbench with less delay but must be > 130 so that TIME_TLOW can be reached
    localparam TIME_THDSTA = int'(600/CLK_PERIOD);         // 0.6 us hold time 
    localparam TIME_TSUSTA = int'(600/CLK_PERIOD);         // 0.6 us hold time 
    localparam TIME_THIGH  = int'(600/CLK_PERIOD);         // 0.6 us hold time 
    localparam TIME_TLOW   = int'(1300/CLK_PERIOD);        // 1.3 us hold time for low pulse 
    localparam TIME_TSUDAT = int'(20/CLK_PERIOD);          // 0.02 us data setup time
    localparam TIME_TSUSTO = int'(600/CLK_PERIOD);         // 0.03 us data hold time
    localparam TIME_THDDAT = int'(30/CLK_PERIOD);          // 0.03 us data hold time
    enum bit [2:0] {IDLE, START, TIME_LOW, TIME_SETUP, TIME_HIGH, TIME_HOLD, TIME_STOP} i2c_states;
    
    localparam I2CBITS = 1 +        // start
                         7 +        // 7 bits for address
                         1 +        // 1 bit for read
                         1 +        // 1 bit for ack back
                         8 +        // 8 bits upper data
                         1 +        // 1 bit for ack
                         8 +        // 8 bits lower data
                         1 +        // 1 bit for ack
                         1 + 1;     // 1 bit for stop

                         
    logic [I2CBITS-1:0] i2c_data;
    logic [I2CBITS-1:0] i2c_write_en;
    logic [I2CBITS-1:0] i2c_read_en;   
    logic               scl_en = 0, sda_en = 0;
    logic [15:0]        temp_data;  
    
    // bit_count to keep track of                  
    logic [$clog2(I2CBITS)-1:0]   bit_count = 0;
    logic [$clog2(TIME_1SEC)-1:0] counter   = 0;
    
    // SCL and SDA left floating when 1 due to pull up resistor to +Vcc
    assign TMP_SCL = scl_en ? 1'bz : 1'b0; 
    assign TMP_SDA = sda_en ? 1'bz : 1'b0;
    
    assign read_en = i2c_read_en[I2CBITS - bit_count - 1];
    
    
    always_ff@(posedge clk)
    begin
        scl_en  <= 1; // SCL default 1 unless we are pulsing
        sda_en  <= ~i2c_write_en[I2CBITS - bit_count - 1] | i2c_data[I2CBITS - bit_count - 1];
        counter <= counter + 1;
               
        case(i2c_states)
        
            IDLE:
            begin
                i2c_data =       {
                                    1'b0,           // start bit
                                    ADT7420_ADDR,   // slave addr
                                    read_bit,
                                    ack_bit,
                                    8'h00,          // reading upper 8 bits of data
                                    ack_bit,
                                    8'h00,          // reading lower 8 bits of data
                                    ~ack_bit,
                                    1'b0,           // stop bit
                                    1'b1            // stop bit into idle state                            
                                 };
                           
               i2c_write_en =    {
                                    1'b1,           // start
                                    7'h7F,          // write slave addr
                                    1'b1,           // write read
                                    1'b0,           // write ack
                                    8'h00,          // reading upper byte, no writing
                                    1'b1,           // write ack
                                    8'h00,          // reading lower byte, no writing
                                    1'b1,           // send nack
                                    1'b1,           // send stop
                                    1'b1            // send stop into idle state
                                 }; 
               
               // only 1 when reading temperature data
               i2c_read_en =    {
                                    1'b0,           
                                    7'h00,          
                                    1'b0,           
                                    1'b0,           
                                    8'hff,          // reading upper byte
                                    1'b0,           
                                    8'hff,          // reading lower byte
                                    1'b0,           
                                    1'b0,           
                                    1'b0            
                                };
               
               bit_count        <= 0;
               sda_en           <= 1; // sda high for IDLE state 
                           
               if(counter == TIME_1SEC)
               begin
                    temp_data  <= 0;
                    i2c_states <= START;
                    counter    <= 0;
                    sda_en     <= 0;        // SDA line is lowered during start
               end
               else
                    i2c_states <= IDLE;
               
            end
            
            START:
            begin
                // data line pulses low during start
                sda_en          <= 0;
                
                if(counter == TIME_THDSTA)
                begin
                    // hold time done so clock pulses low
                    scl_en      <= 0;
                    i2c_states  <= TIME_LOW;
                    counter     <= 0;
                end
                else
                    i2c_states  <= START;
                
                
            end
            
            TIME_LOW:
            begin
                // clock pulses low 
                scl_en          <= 0; 
                
                // 1.3 us SCL low
                if(counter == TIME_TLOW) 
                begin
                    counter    <= 0;
                    bit_count  <= bit_count + 1;
                    i2c_states <= TIME_SETUP;
                end
                else
                    i2c_states <= TIME_LOW;
                
            end
            
            TIME_SETUP:
            begin
                scl_en <= 0; // clock is dropped during setup time
                if(counter == TIME_TSUSTA)
                begin
                    counter    <= 0;
                    i2c_states <= TIME_HIGH;
                end
            end
            
            TIME_HIGH:
            begin
                scl_en <= 1; // clock is high during data out/in
                
                if(counter == TIME_THIGH)
                begin
                    if(read_en) temp_data <= (temp_data << 1) | TMP_SDA; // shift in SDA bit
                    counter               <= 0;
                    i2c_states            <= TIME_HOLD;
                end
                
            end
            
            TIME_HOLD:
            begin
                scl_en <= 0;
                // hold data state, clock is low
                if(counter == TIME_THDDAT)
                begin
                    counter <= 0;
                    i2c_states <= (bit_count == I2CBITS) ? TIME_STOP : TIME_LOW; // If we didn't finish the transaction go back to TIME_LOW else send STOP
                end
                
                
            end
            
            TIME_STOP:
            begin
                // setup time for stop
                if(counter == TIME_TSUSTO)
                begin
                   counter      <= 0;
                   i2c_states   <= IDLE;                    
                end
            end
                   
        endcase
        
    end
    
    logic [15:0] fraction_table[16];
    
    initial 
    begin
        for (int i = 0; i < 16; i++) fraction_table[i] = i*625;
    end
    
    logic [15:0] fraction_scaled = fraction_table[temp_data[6:3]];

    assign LED      = temp_data[15:3];
    
    bit [7:0] int_bcd_out;
    bit [3:0] frac_bcd_out;
    
    double_dabble int_bcd(temp_data[14:7], int_bcd_out);
    
    double_dabble_fraction frac_bcd(fraction_scaled, frac_bcd_out);
    
    assign bcd_temp = {int_bcd_out, frac_bcd_out};
    
      
    
endmodule
