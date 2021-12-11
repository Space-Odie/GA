/*----------------------------------------------------------
 526 L         Final Exam         Fall 2020
 -----------------------------------------------------------
 File Name: File_Name.sv
 Author: Ian O'Donnell
 -----------------------------------------------------------
 Version     Date            Description
 1.0         12-08-2020      Initial Release
 -----------------------------------------------------------
 Purpose: 
 ----------------------------------------------------------*/
 
`timescale 1ns/1ns
module tb_Genetic_Algorithm(); 

    parameter SIZE = 8; //default 8 bit (max value is 180 for a coordinate)

    //inputs
    reg CLK, RESET;
    wire DOUT;
    Genetic_Algorithm UUT(CLK, RESET, DOUT); 

   //Create Clock Generator
    initial begin
        CLK = 1'b0;
        forever #5 CLK = ~CLK;
     end


   /*initial 
    $monitorb("%d CLK = %b RESET = %b", $time, CLK, RESET); 
*/
   initial 
   begin 

    $display("Start of simulation");

    RESET = 0;
    #20 RESET = 1; 


    $strobe("End of Simulation");
    
   end

endmodule