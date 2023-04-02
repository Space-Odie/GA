//TODO - make synthesizable
// 1. hardcode the coordinates (32 int)
// 2. hardcode the population


`timescale 1ns/1ns
import my_pkg ::*;
module Genetic_Algorithm(CLK, RESET, DOUT);

    input CLK;
    input RESET;
    output reg [SIZE - 1:0] DOUT;   //without an output i was getting error (PLACE 30-494) THE DESIGN IS EMPTY

    //INITIALIZE IO
    reg [SIZE:0] COORDINATES [0: (NumOfCities*2)-1];                //read cities x and y each city: EXAMPLE (10 CITIES = 0:21 = 20 CITIES)
    integer Index[0 : NumOfCities - 1];                             //Represents the city coordinate - as read from file
    integer RouteIndex[ 0: Population_Size - 1];
    reg [SIZE - 1:0] POPULATION [0: (NumOfCities * Population_Size)-1];
    
    reg [SIZE - 1:0] distance_arr [0: (NumOfCities * Population_Size)-1];  //using this for testing purposes.
     
    integer i, j, city, route, count, temp1, temp2;
    
    //State_2 I/O
    reg [SIZE - 1:0] city_distance;
    
    //OUTPUT - Digital Output of most optimized distance value

     //max distance between two points is ~ 370 (0,0 ->360,90)? how to make this scale with number of populations? maybe just after doing a lot of tests this can be adjusted. 
    integer route_distance;        
    integer FITNESS [0: Population_Size-1];
    integer SORTED_FITNESS [0: Population_Size-1];
    //States
    STATES STATE, NEXT_STATE;
    

    //LSFR IO
    reg [9:0] TAPS;            
    reg [9:0] RAND_OUT;
    reg [3:0] BIT4_RAND;
    reg [5:0] BIT6_RAND;
    reg [6:0] BIT7_RAND; 
    reg [7:0] BIT8_RAND;
    reg [9:0] BIT10_RAND, CHANCE;

    //state_4 I/O (selection)
    integer SELECTION_ARR [0: Population_Size-1];
    reg [7:0] pick, selected1, selected2, selected3, selected4;
    
    //Breading I/O
    reg [7:0] PARENT1, PARENT2, cut_point, p;
    reg DUPLICATE;
    integer CHILD_STAGE; // COunter to determine what stage breeding is on
    
    //mutation state I/O
    reg [SIZE - 1:0] CHILD_POPULATION [0: (NumOfCities * Population_Size)-1]; //child population
    integer childIndex, CITY1, CITY2;
    
    // Next_Gen I/O
    integer iteration;
    reg [SIZE - 1:0] BEST_CHROMOSOMES [0: Population_Size-1];
    integer GEN_STAGE;
    
    initial begin
        //not synthsizable but make sure that this can be applied to the project folder, not personal computer
      //  $readmemh("C:\\Users\\Tungsten\\Desktop\\College\\data_file.txt", COORDINATES);  
      
iteration <= 0;

COORDINATES <= 
    {
    129,62,132,94,104,162,91,84,135,68,125,100,126,41,98,65,10,8,-15,33,-33,-63,6,-4,11,-30,27,-35,120,-30,144,0,100,-7,145,19,77,39,
    275,39,-8,47,3,66,-20,128,152,128,-71,86,37,80,38,82,18,64,20,53,53,34,34,64,92,64
    };


POPULATION <= 
    {
          2,
          4,
         40,
         56,
         16,
          0,
         42,
         28,
         62,
         48,
         24,
         54,
         26,
          6,
         22,
         60,
         20,
         34,
         58,
         18,
         46,
         44,
         32,
          8,
         30,
         12,
         36,
         14,
         10,
         52,
         50,
         38,
          2,
         30,
         20,
         10,
         34,
         50,
         58,
         60,
         18,
         26,
         38,
         28,
         12,
          6,
         16,
         54,
         52,
         46,
          0,
          4,
         24,
         40,
         36,
         22,
         48,
          8,
         32,
         56,
         42,
         14,
         62,
         44,
          2,
         32,
         22,
          8,
         60,
         36,
         20,
          4,
         52,
         44,
         10,
         42,
         16,
         34,
         28,
         14,
         62,
         12,
         26,
         46,
         58,
         38,
         24,
         48,
         50,
         30,
         40,
          0,
          6,
         54,
         18,
         56,
         22,
         24,
         14,
         52,
          6,
         46,
          0,
         44,
          2,
         58,
         30,
          4,
         50,
         62,
         32,
         12,
         26,
         16,
         10,
         42,
         36,
         38,
         28,
         34,
         40,
         60,
         54,
         48,
         56,
          8,
         18,
         20,
         18,
         40,
          4,
         30,
         20,
         62,
         26,
         16,
         54,
         38,
          6,
         24,
         32,
         22,
         10,
         56,
          0,
         50,
         60,
         14,
         48,
         58,
         34,
          8,
         28,
         42,
         44,
          2,
         46,
         52,
         12,
         36,
         54,
         60,
         36,
         40,
         26,
         30,
         50,
         32,
         48,
         12,
          2,
         14,
          4,
         34,
          8,
         52,
         28,
         46,
         18,
         16,
         42,
         56,
         20,
          6,
         10,
         62,
         44,
         38,
         58,
         24,
         22,
          0,
         34,
         56,
         16,
         42,
         44,
         18,
         36,
          4,
         60,
          8,
         10,
          6,
         58,
         24,
         40,
         48,
         52,
         28,
          0,
         50,
          2,
         20,
         26,
         46,
         12,
         54,
         32,
         14,
         62,
         30,
         38,
         22,
         24,
         54,
         56,
         30,
         38,
         28,
          0,
         36,
         52,
         34,
         18,
         32,
         20,
         12,
         46,
          8,
         62,
         40,
         42,
         48,
         58,
         16,
          6,
         10,
         60,
         44,
         26,
          2,
         22,
          4,
         50,
         14,
         52,
         28,
         50,
         46,
         60,
          2,
         54,
         38,
         20,
          8,
         18,
         16,
         22,
         24,
         36,
         32,
         56,
         40,
          0,
         10,
          6,
         48,
         44,
         30,
         12,
         42,
         14,
         26,
         62,
         58,
         34,
          4,
         14,
         16,
         36,
          4,
         10,
          6,
         56,
         20,
         32,
         18,
         22,
          8,
         38,
         40,
         28,
         46,
         26,
         60,
         62,
          2,
         12,
         58,
         42,
         48,
          0,
         44,
         54,
         50,
         30,
         52,
         24,
         34,
         58,
         34,
         44,
         14,
          2,
          0,
         22,
         60,
         56,
         40,
          8,
          6,
         42,
         54,
         26,
         36,
         12,
         10,
         38,
         30,
         50,
         20,
          4,
         46,
         24,
         28,
         16,
         18,
         62,
         32,
         52,
         48,
         16,
          0,
         56,
         28,
         38,
         22,
         46,
         30,
         48,
         40,
         24,
         34,
         60,
          8,
          2,
         50,
         58,
         54,
         20,
         36,
         42,
         18,
         26,
         32,
         14,
         62,
         12,
          4,
         10,
          6,
         44,
         52,
         30,
         44,
         46,
          2,
         28,
          6,
         58,
         56,
          4,
         32,
         18,
         62,
         14,
         40,
         22,
         10,
         60,
         34,
         20,
         48,
         12,
          0,
         52,
         42,
         54,
         50,
         26,
         38,
          8,
         36,
         16,
         24,
          4,
         22,
         20,
         46,
         34,
         26,
         38,
         40,
         60,
         50,
         12,
         48,
          6,
         42,
         10,
         36,
         28,
          2,
         32,
         30,
         18,
         62,
         58,
         52,
         54,
         56,
          0,
         14,
         16,
         24,
          8,
         44,
         60,
         38,
         10,
         46,
         28,
          2,
         50,
         18,
         16,
         36,
         44,
         12,
         34,
         48,
         62,
         56,
         40,
          4,
         20,
         26,
         58,
         52,
         24,
          8,
         30,
          6,
          0,
         14,
         32,
         22,
         54,
         42,
         16,
         60,
         14,
          4,
         30,
         20,
          2,
         24,
         52,
         12,
         56,
         28,
         34,
         38,
         44,
          0,
          8,
         50,
         18,
         42,
         46,
         10,
         40,
         62,
         58,
          6,
         22,
         32,
         54,
         48,
         26,
         36
    };

NEXT_STATE <= STATE_1;     

        //initialize first population . .   
    end 
    

    always @ (CLK, i) begin
        if (RESET) begin   // Add these during Next Gen Sequence also
            RAND_OUT <= 10'hA;           //initial value
            TAPS <= 10'hB8;              //set a value for TAPS
        end 
        else begin

            RAND_OUT <= RAND_OUT >> 1;
            RAND_OUT[9] <= RAND_OUT[0] ^
                                ((TAPS[9]) ? RAND_OUT[1] : 0) ^
                                ((TAPS[8]) ? RAND_OUT[2] : 0) ^
                                ((TAPS[7]) ? RAND_OUT[3] : 0) ^
                                ((TAPS[5]) ? RAND_OUT[4] : 0) ^
                                ((TAPS[4]) ? RAND_OUT[5] : 0) ^
                                ((TAPS[3]) ? RAND_OUT[6] : 0) ^
                                ((TAPS[2]) ? RAND_OUT[7] : 0) ^
                                ((TAPS[1]) ? RAND_OUT[8] : 0) ^
                                ((TAPS[0]) ? RAND_OUT[9] : 0);
        
          
        end 
        
        BIT4_RAND[3:0] <= RAND_OUT[4:1];    //Randum Number 0-7. 
        BIT6_RAND[5:0] <= RAND_OUT[6:1];
        BIT7_RAND[6:0] <= RAND_OUT[7:1];
        BIT8_RAND[7:0] <= RAND_OUT[7:0];    //Random Number 0-15
        BIT10_RAND[9:0] <= RAND_OUT[9:0];

        pick <= BIT4_RAND;
        selected1 <= BIT10_RAND[9:6]; 
        selected2 <= BIT10_RAND[8:5];
        selected3 <= BIT10_RAND[7:4];
        selected4 <= BIT10_RAND[6:3];

        //VARIABLES FOR MUTATION   (fix this so the bits are automatically based on the # of cities to closest binary?)
        CITY1 <= BIT10_RAND[9:8];
        CITY2 <= BIT10_RAND[6:5];
        CHANCE <= BIT8_RAND;



     end 

    always @ (CLK)
    begin

        if (!RESET) 
        begin
    
            case (STATE)
            
            //  Initialize   
            //  This will create an Index based on the number of Cities / PopulationSize
            //
                STATE_1: begin      //Initialize
                        
                    for(i=0; i<=NumOfCities; i++)
                    begin
                        Index[i] <= 2*i;
                    end
                    
                    for (i=0; i<= Population_Size; i++)
                    begin
                        RouteIndex[i] = i;
                    end 
                    
                   /*
                    for (route=0; route < Population_Size; route++)  //removed <= as it was one additional route added to population. 
                    begin
                        Index.shuffle();
                        for (city=0; city < NumOfCities; city++)  
                        begin
                            POPULATION[((route*NumOfCities) + city)] <= Index[city];
                            $display("%d,",Index[city]);
                        end 
                    end 
                    */
                    NEXT_STATE <= STATE_2;

                    //initialize

                end //End of Initialization/State_1

                // Calculate Fitness
                // This will calculate the total distance for each route and store it into a Fitness[Array]
                //

                STATE_2: begin      //Calculate Fitness
                    
                    for (route=0; route <= Population_Size; route++)
                    begin  
                        route_distance = 0;

                        for (city=0; city < NumOfCities; city++)begin
                            //Distance(Coordinates) 
                                
                            if (city < (NumOfCities-1))                     //X1                                    //y1                                    //x2                                        x4                                  output
                                DISTANCE(COORDINATES[POPULATION[(route*NumOfCities+city)]], COORDINATES[POPULATION[(route*NumOfCities)+city]+1], COORDINATES[POPULATION[(route*NumOfCities)+city+1]], COORDINATES[POPULATION[(route*NumOfCities)+city+1] + 1], city_distance);
                            if (city == (NumOfCities-1)) //last location to starting location
                                DISTANCE(COORDINATES[POPULATION[(route*NumOfCities+city)]], COORDINATES[POPULATION[(route*NumOfCities)+city]+1], COORDINATES[POPULATION[(route*NumOfCities)+0]], COORDINATES[POPULATION[(route*NumOfCities)+ 0 ] + 1], city_distance);
                            
                            distance_arr[route*NumOfCities+city] <= city_distance;
                            route_distance = route_distance + city_distance;
                        end 
                        
                        FITNESS[route] <= route_distance;       //for some reason this is going in backwards . . . (first coordinate is last coordinate...) This matters. 
                       // route_distance <= 0;
                    end 
                    NEXT_STATE <= STATE_3;
                    SORTED_FITNESS <= FITNESS;


                 
                end //End of Calculating Distance // State 2

                //Sort Fitness
                // This will go through the Fitness Array and sort the total distance from Minimum to Maximum and Store it in Sorted_Fitness[array]
                
                STATE_3: begin      //Sort Fitness

                    for (i = Population_Size; i > 0; i--) begin 
                        for (j = 0; j < Population_Size; j++) begin            
                            if (SORTED_FITNESS[j] > SORTED_FITNESS[j + 1]) begin
                                temp1 = SORTED_FITNESS[j];
                                SORTED_FITNESS[j] = SORTED_FITNESS[j + 1];
                                SORTED_FITNESS[j + 1] = temp1;
                                
                                temp2 = RouteIndex[j];
                                RouteIndex[j] = RouteIndex[j + 1];
                                RouteIndex[j + 1] = temp2;
                                
                            end 
                        end
                    end
                            
                    NEXT_STATE <= STATE_4;
                end

                // Elitism
                // This will take the X amount of chromosomes and place it directly into the child population. also pass to selection array? (this may not be needed)
                //

                STATE_4: begin      //Elitism based on elitismSize
                    for (i = 0; i < ElitismSize; i++) 
                        begin
                            SELECTION_ARR[i] <= RouteIndex[i];

                            //pass elite directly to children

                            for (city=0; city <= NumOfCities; city++)  //Pass Elitism To Child Array Population
                                CHILD_POPULATION[(i * NumOfCities) + city] <= POPULATION[((RouteIndex[i]*NumOfCities) + city)];
                                    
                        end 

                    NEXT_STATE <= STATE_5;

                end      

                // Selection
                // Create a Selection by picking population using roulette method. This will create a new array (Selection_arr[array]) of a "more fit" population and eliminate most of the "unfit" loot
                //
                STATE_5: begin      
                    if (i < Population_Size)
                    begin



                        if (selected1 < pick)    //if 10 < 5
                        begin
                            SELECTION_ARR[i] = RouteIndex[selected1];
                        end 
                        else if (selected2 < pick) 
                        begin
                            SELECTION_ARR[i] = RouteIndex[selected2];
                        end
                        else if (selected3 < pick) 
                        begin
                            SELECTION_ARR[i] = RouteIndex[selected3];
                        end
                        else if (selected4 < pick) 
                        begin
                            SELECTION_ARR[i] = RouteIndex[selected4];
                        end
                        else 
                        begin
                            SELECTION_ARR[i] = RouteIndex[pick];
                        end
                    i++;

                    end 
                    else if (i >= Population_Size - ElitismSize) 
                    begin 
                        route <= ElitismSize - 1;
                        city <= 0;
                        childIndex <= ElitismSize;
                        NEXT_STATE <= STATE_6;
                    end 
                    
                end 

                //Mutation
                //There will be a "X"% chance of Mutation Rate for each route in the population. Each POPULATION - not Selection Array - will go through mutation chance.
                // If it does go through mutation, then it gets sent straight to the child population. Does not get used for breeding. 

                STATE_6: begin     //Mutation

                    if (route < Population_Size)
                    begin
                        if (CHANCE <= MUTATION_RATE)
                        begin
                            $display("mutation occured on route: %d |Route Index %d| chance %d", route, RouteIndex[route], CHANCE);
//                            POPULATION[((RouteIndex[route] * NumofCities) + CITY1)] <= POPULATION[((RouteIndex[route] *NumofCities) + CITY2)];
//                            POPULATION[((RouteIndex[route] * NumofCities) + CITY2)] <= POPULATION[((RouteIndex[route] *NumofCities) + CITY1)];
                            $display("CITY1 | CITY2", CITY1, CITY2);



                            for (city=0; city <= NumOfCities; city++)  //pass mutated to child population
                                CHILD_POPULATION[(childIndex * NumOfCities) + city] <= POPULATION[((RouteIndex[route]*NumOfCities) + city)]; 

                            //mutate the child by swapping two cities. 
                           CHILD_POPULATION[((childIndex * NumOfCities) + CITY1)] <= POPULATION[((RouteIndex[route] *NumOfCities) + CITY2)];
                           CHILD_POPULATION[((childIndex * NumOfCities) + CITY2)] <= POPULATION[((RouteIndex[route] *NumOfCities) + CITY1)];
                            

                            childIndex++;
                        end 
                        route++;
                    end 

                    if (route >= Population_Size)
                    begin
                        NEXT_STATE <= STATE_7;
                       // NEXT_STATE <= STATE_9; //go to state 9 so i can just observe mutation 
                        p <= 0;
                        CHILD_STAGE <= 0;

                    end 
                end 


                //Breeding
                /*
                Inputs: Parent1, Parent 2. 
                    These are randomly selected WITHIN SELECTION ARRAY. 

                */
                //
                STATE_7: begin     
                    
    
                    if (CHILD_STAGE == 0) //Assign new parents and a new cut point. 
                    begin 
                        cut_point <= BIT4_RAND[1:0]; //add this to LFSR
                        p <= 0;


                        PARENT1 <= BIT10_RAND[8:5];     //change this value based on POPULATION SIZE   (CURRENTLY 16)
                        PARENT2 <= BIT10_RAND[7:4];     // change this value based on POPULATION SIZE  (CURRENTLY 16)
                        DUPLICATE <= 0; 
                        CHILD_STAGE <= 1;
 
                    end 


                    if (CHILD_STAGE == 1) // Grab the "Genes" from Parent 1. 
                    begin
                        if( childIndex < Population_Size)
                        begin       

                            $display("------------------|Displaying childIndex : %d ------------------| p = %d ", childIndex, p);
                            $display("PARENT 1: %d | PARENT 2: %d || cut point :%d", PARENT1, PARENT2, cut_point);
                            //Must create edge cases for cut point = 0;


                            if (cut_point > 0) 
                            begin
                            
                                for (city=0; city < cut_point; city++)
                                begin
                                    //what I want to do here instead is select a population route within the SELECTION ARRAY (Index)
                                    //                                                  <= POPULATION[((SELECTION_ARRAY[PARENT1]) * nUMoFciTIES) + CITY)]
                                    CHILD_POPULATION[((childIndex*NumOfCities) + city)] <= POPULATION[(((SELECTION_ARR[PARENT1]) * NumOfCities) + city)];   //move the first part of parent 1's route to the "child"
                                    $display("Adding Parent 1 city %d to Child:", POPULATION[(((SELECTION_ARR[PARENT1])*NumOfCities) + city)]);
                                end 
                            end 

                            city <= 0;
                            CHILD_STAGE <= 2; 
                        end 

                        if (childIndex == Population_Size) 
                        begin
                            CHILD_STAGE <= 0; //breeding is done. 
                            GEN_STAGE <= 0;
                            NEXT_STATE <= STATE_8; 
                        end            
                    end  

                if (CHILD_STAGE == 2) // Grab a "Genes" from Parent 2 and check for duplicates
                begin

                    if (cut_point == 0) begin

                        for (city=0; city < NumOfCities; city++)
                        begin
                            CHILD_POPULATION[((childIndex*NumOfCities) + city)] <= POPULATION[(((SELECTION_ARR[PARENT2]) * NumOfCities) + city)];   //move the first part of parent 1's route to the "child"
                            $display("CP = 0 !!  Adding Parent 2 city %d to Child:", POPULATION[(((SELECTION_ARR[PARENT2])*NumOfCities) + city)]);
                        end 
                    end 


                    if (city <= NumOfCities) 
                    begin
                        for (j=0; j<= cut_point; j++)
                        begin
                            if ( CHILD_POPULATION[((childIndex*NumOfCities) + j)] == POPULATION[(((SELECTION_ARR[PARENT2])*NumOfCities) + city)] )
                            begin 
                                DUPLICATE <= 1;
                                $display("duplicate found: %d ---- Activating", POPULATION[(((SELECTION_ARR[PARENT2])*NumOfCities) + city)]);
                                break; //do not need to continue the loop once a duplicate is found. 
                            end
                        end 

                        CHILD_STAGE <= 3;
                    end 

                    if (city == NumOfCities)    //CHROMOSONE COMPLETED, MOVE TO NEXT. 
                    begin
                        CHILD_STAGE <= 0;
                        childIndex++; 

                    end 
                end 
                if (CHILD_STAGE == 3) // if gene is new, add it to the chromosone. 
                begin
                    if (!DUPLICATE) 
                    begin            
                        CHILD_POPULATION[((childIndex*NumOfCities) + cut_point + p)] <= POPULATION[(((SELECTION_ARR[PARENT2])*NumOfCities) + city)];
                        $display("Adding Parent 2 city %d to Child", POPULATION[(((SELECTION_ARR[PARENT2])*NumOfCities) + city)]);
                        p <= p + 1;
                    end 

                    if (DUPLICATE) begin
                        DUPLICATE <= 0;
                    end
                    CHILD_STAGE <= 2; 
                    city++; 
                end 
            end 
            
            //NEXT GEN
            STATE_8: begin 
                if (GEN_STAGE == 0) 
                begin
                    //pass child array to population
                    POPULATION <= CHILD_POPULATION;
                    // pass most fit gene so it can be graphed at the end. CHILD_POPULATION[0] is most fit child, grabbed from elitism. 
                    BEST_CHROMOSOMES[iteration] <= SORTED_FITNESS[0];
                    iteration++;
                    GEN_STAGE <= 1;
                end 

                if (GEN_STAGE == 1) 
                begin
                    // reset any values that need to be rest here. 

                    //reset Route Index (May not be needed but easier for verification)
                    for (i=0; i<= Population_Size; i++)
                        RouteIndex[i] = i;
                     
                    // child population should be set to all value 0s
                    for (i=0; i < (NumOfCities * Population_Size); i++)
                        CHILD_POPULATION[i] <= 0;

                    for (i=0; i < Population_Size; i++) 
                        SORTED_FITNESS[i] <= 0;

                    GEN_STAGE <= 2; 
                end 

                if (GEN_STAGE == 2)   //check if iterations are done. 
                begin 
                    if (iteration < total_iterations)
                    begin
                        NEXT_STATE <= STATE_2; // Find Distance of new Population 
                    end 
                    if (iteration >= total_iterations)
                    begin
                        NEXT_STATE <= STATE_9;
                        $display ("Done with iterations");
                        DOUT = BEST_CHROMOSOMES[iteration-1];
                    end 
                end 
                
            end 
        endcase 
    end
    STATE <= NEXT_STATE;
end   
endmodule 


