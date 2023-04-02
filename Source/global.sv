`timescale 1ns/1ns

package my_pkg;


  // Add localparameters here
    parameter Number_of_Cities = 8;
    parameter Population_Size = 100;
    parameter eliteSize = 20;
    parameter mutationRate = 4; //.04%
    parameter generations = 500;

  //Add Tasks / Functions here
  

    typedef enum reg [2:0] {INITIALIZE,
                            RANK_ROUTES, 
                            SELECTION, 
                            BREED, 
                            MUTATE, 
                            NEXT_GEN,
                            DONE} STATES;
      
endpackage
