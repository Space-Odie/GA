`timescale 1ns/1ns
module LFSR(CLK, RST, TAPS, INITIAL_VALUE, RAND_OUT, BIT3_RAND, BIT8_RAND);

    parameter SIZE = 8; //max value 
   
    input   CLK;
    input   RST;
    input   [SIZE-1:0] TAPS;            //determine where to tap off the LFSR for the XOR gates. 
    input   [SIZE-1:0] INITIAL_VALUE;   //first value to load into LSFR
    
    output  reg [SIZE-1:0] RAND_OUT;
    output reg [3:0] BIT3_RAND; 
    output reg [7:0] BIT8_RAND;



    always @ (posedge CLK, negedge RST)
    begin
        if (!RST) 
            RAND_OUT <= INITIAL_VALUE;
            
        else begin
            RAND_OUT <= RAND_OUT >> 1;
            RAND_OUT[7] <= RAND_OUT[0] ^
                                 ((TAPS[6]) ? RAND_OUT[1] : 0) ^
                                 ((TAPS[5]) ? RAND_OUT[2] : 0) ^
                                 ((TAPS[4]) ? RAND_OUT[3] : 0) ^
                                 ((TAPS[3]) ? RAND_OUT[4] : 0) ^
                                 ((TAPS[2]) ? RAND_OUT[5] : 0) ^
                                 ((TAPS[1]) ? RAND_OUT[6] : 0) ^
                                 ((TAPS[0]) ? RAND_OUT[7] : 0);
        end
        

            BIT3_RAND[3:0] <= RAND_OUT[4:1];    //Randum Number 0-7. 
            BIT8_RAND[7:0] <= RAND_OUT[7:0];    //Random Number 0-15

    end
endmodule 