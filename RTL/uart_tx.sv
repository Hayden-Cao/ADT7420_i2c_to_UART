`timescale 1ns / 1ps

module uart_tx
#(parameter NUM_BITS = 8, BAUD_RATE = 115200, MASTER_CLK_FREQ = 100_000_000)
(
    input wire clk,
    input wire reset,
    input logic [NUM_BITS-1:0] tx_byte,
    input logic data_valid,
    output logic tx_serial,
    output logic ready
    
);

    localparam PULSE_WIDTH = MASTER_CLK_FREQ / BAUD_RATE;
    localparam PULSE_WIDTH_COUNTER_BITS = $clog2(PULSE_WIDTH);
    localparam HALF_PULSE_WIDTH = PULSE_WIDTH / 2;
    localparam BIT_COUNTER_BITS = $clog2(NUM_BITS);
    
    logic [BIT_COUNTER_BITS-1:0] bit_count = 0;
    logic [PULSE_WIDTH_COUNTER_BITS-1:0] pulse_count = 0;
    logic [NUM_BITS-1:0] i_tx_byte = 0;
    
    enum {IDLE, START, DATA, STOP, CLEANUP} state;
    
    
    always_ff@(posedge clk, posedge reset)
    begin
        
        if(reset)
        begin
            state <= IDLE;
            bit_count <= 0;
            pulse_count <= 0;
            ready <= 1;
            tx_serial <= 1;
        end
        else 
        begin
                case(state)
                
                IDLE:
                begin
                
                    tx_serial <= 1;
                    ready <= 1;
                    pulse_count <= 0;
                    bit_count <= 0;
                    
                    if(data_valid)
                    begin
                        i_tx_byte <= tx_byte;
                        state <= START;
                    end
                    else
                        state <= IDLE;
                end
                
                START:
                begin
                    tx_serial <= 0;
                    ready <= 0;
                    if(pulse_count < PULSE_WIDTH -1)
                    begin
                        pulse_count <= pulse_count + 1;
                        state <= START;
                    end
                    else
                    begin
                        pulse_count <= 0;
                        state <= DATA;
                    end
                    
                end
                
                DATA:
                begin
                    tx_serial <= i_tx_byte[bit_count];
                    
                    if(pulse_count < PULSE_WIDTH -1)
                    begin
                        pulse_count <= pulse_count + 1;
                        state <= DATA;
                    end
                    else
                    begin
                        pulse_count <= 0;
                        
                        if(bit_count < 7)
                        begin
                            bit_count <= bit_count + 1;
                            state <= DATA;
                        end
                        else
                        begin
                            bit_count <= 0;
                            state <= STOP;
                        end
                        
                    end                
                    
                end
                
                STOP:
                begin
                    tx_serial <= 1;
                    
                    if(pulse_count < PULSE_WIDTH-1)
                    begin
                        pulse_count <= pulse_count + 1;
                        state <= STOP;
                    end
                    else
                    begin
                        pulse_count <= 0;
                        state <= CLEANUP;
                    end
                    
                end
                
                CLEANUP:
                begin
                    // stay here for 1 clk cycle to avoid any overlapping issues
                    state <= IDLE;
                end
                
                
                default: state <= IDLE;
                      
            endcase
        end
        
    end


endmodule
