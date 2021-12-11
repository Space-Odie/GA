`timescale 1ns/1ns

package global;

    //Add enum to global package
        $display()
    typedef enum reg [2:0] {INITIALIZE,
                            RANK_ROUTES, 
                            SELECTION, 
                            BREED, 
                            MUTATE, 
                            NEXT_GEN} STATES;

  // Add localparameters here
    Local parameter Number_of_Cities = 8;
    local parameter Population_Size = 100;
    Local parameter eliteSize = 20;
    local Parameter mutationRate = 4; //.04%
    local parameter generations = 500;

  //Add Tasks / Functions here
  
      
endpackage
