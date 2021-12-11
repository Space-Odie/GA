
module tb_LSFR;
    reg CLK;
    reg RST;
    reg [7:0] TAPS;
    reg [7:0] INITIAL_VALUE;
    wire [7:0] RAND_OUT, BIT8_RAND;
    wire [3:0] BIT3_RAND;
    integer count;

    LFSR UUT(CLK, RST, TAPS, INITIAL_VALUE , RAND_OUT, BIT3_RAND, BIT8_RAND);

    initial
    begin
        #0 

        RST  = 1;
        CLK    = 0;
        count = 0;

        #10
        INITIAL_VALUE = 8'hA;
        TAPS = 8'hB8;
        RST = 0;

        #10
        RST = 1;

        #512
        $finish;
    end

    always #1 begin
        CLK = !CLK;
        if (CLK) count = count + 1;
    end
endmodule