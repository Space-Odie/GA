`timescale 1ns/1ns

package my_pkg;

//DEFINES

//PARAMETERS
    parameter SIZE = 8;                 //default 8 bit (max value is 180 for a coordinate)
    parameter NumOfCities = 32;
    parameter Population_Size = 16; 
    parameter ElitismSize = 3;
    parameter total_iterations = 2;
    
    parameter MUTATION_RATE = 3; // Population_Size << 3;
    
    
    //typedef
     typedef enum reg [3:0] {STATE_1,
                        STATE_2, 
                        STATE_3, 
                        STATE_4, 
                        STATE_5, 
                        STATE_6,
                        STATE_7,
                        STATE_8,
                        STATE_9,
                        STATE_10,
                        STATE_11,
                        STATE_12,
                        STATE_13,
                        STATE_14,
                        STATE_15,
                        STATE_16} STATES;
        
////////////////////////////////////////////////////////////////////////////    
   /* 
   //       Distance Task
   */
      task automatic DISTANCE;
    /* 
        Purpose: Perform  the Distance Formula: ?[(x? - x?)² + (y? - y?)²]. 
        Input: Coordinates
        Output: Distance Value 
        
    */
        input [SIZE-1:0] X1, Y1, X2, Y2;
        output [SIZE:0] DISTANCE;
        
        reg [SIZE-1:0] xtemp, ytemp;
        reg [(SIZE*2)-1:0] X, Y;
        reg [SIZE*2:0] d;   //16

        //Sqrt components
        integer i, a, square, delta;
        
        begin
            //Subtraction (only positive values)
            xtemp = (X2 > X1) ? (X2 - X1) : (X1 - X2); 
            ytemp = (Y2 > Y1) ? (Y2 - Y1) : (Y1 - Y2);

            //Square
            X = xtemp * xtemp;
            Y = ytemp * ytemp;
            
            //Addition
            d = X + Y;
            
            //Square Root
            square = 1;
            delta = 3;
            while (square <= d) begin
                square = square + delta;
                delta = delta + 2;
            end
            DISTANCE = ((delta/2)-1);   //Result of Square Root
         
      //  $display("X1 = %d || Y1 = %d || X2 = %d Y2 = %d",X1, X2,Y2, Y1); 
      //  $display("DISTANCE = %d", DISTANCE);    
     
        end 
    endtask 
////////////////////////////////////////////////////////////////////////////    

      task automatic FindMAX;
    /* 
        Purpose: 
        Input: 
        To Use: SORT(Input Unsorted Array, Output Sorted Array) 
        
    */
        input integer FITNESS [Population_Size-1 : 0];
        output [SIZE-1:0] index;
        
        integer temp = -1;
        integer i, j;

        begin
            for (i=0; i<Population_Size; i++)
            begin
                if (FITNESS[i] > temp) begin
                    temp = FITNESS[i];
                    index = i;
                end
            end 
            //DOUT = temp;
                                   
        end 
    endtask 

///////////////////////////////////////////////////////////////////////////////////
                    

endpackage
