`timescale 1ns/1ns
module Genetic_Algorithm(CLK, RESET, DOUT);

    import my_pkg ::*;

    parameter SIZE = 8; //default 8 bit (max value is 180 for a coordinate)
    parameter NumOfCities = 24;
    parameter Population_Size = 100; //100
    parameter parent_popsize = 32;   //64
    parameter total_iterations = 1000;
    parameter selection_range = 20;
    //declare io
    input CLK;
    input RESET;
    output reg DOUT;

    
    //declare reg (internal connections)
    reg initialize;                
    
    //Declare enum type
    STATES STATE, NEXT_STATE;

    
    //declare the remaining inputs in the order that I use them for now. 

    

    //LSFR IO
    reg [SIZE-1:0] TAPS;            
    reg [SIZE-1:0] RAND_OUT;
    reg [3:0] BIT3_RAND;
    reg [5:0] BIT6_RAND;
    reg [6:0] BIT7_RAND; 
    reg [7:0] BIT8_RAND;

    
    //INITIALIZE IO
    integer INIT_STAGE;
    reg [SIZE:0] Coordinates [0:(NumOfCities*2)+1];         //read cities x and y each city 
    integer Order[NumOfCities+1];                            //Represents the city coordinate - as read from file
    integer Population [Population_Size+1][NumOfCities+1];    //population of each route
    integer city_distance;
    integer i, j,k, route, for_route, for_city, city; 

    //Rank Routes IO
    integer RANK_STAGE;
    integer Fitness [Population_Size];                      //fitness of each route
    integer route_distance;

    //Selection IO
    integer SELECT_STAGE;
    integer select_1, select_2;
    integer selected,selected_min, selected_max;
    integer parent, count;
    reg [SIZE-1:0] Parent_Route;            //index of the route for the parent selector 
    integer Fit_Parents [Population_Size];   //array of indexes 

    //Breed IO  
    integer Parent1, Parent2;
    integer Child[NumOfCities+1];
    integer parents_selected;           //counter 
    integer cut_point; 
    reg ACTIVE;     //reset = 0
    integer CHILD_STAGE; // COunter to determine what stage breeding is on
    integer p; // p = 0 on reset
    integer CHILD_Population [Population_Size+1][NumOfCities+1];    //population of each route
    
    //Mutate IO
    integer MUTATE_STAGE;
    integer CITY1, CITY2;
    integer MUTATE_SWAP [2];    //hold only two city values that need to be swapped
    //NEXT_GEN IO
    integer GEN_STAGE;
    integer iterations;
    integer temp_distance;
    integer BEST_POP;
    integer BEST_ARRAY[total_iterations+1];
    
    
   task automatic Distance;
    /* 
        Purpose: Perform  the Distance Formula: ?[(x? - x?)² + (y? - y?)²]. 
        Input: Coordinates
        Output: Distance Value 
        
    */
        input [SIZE-1:0] X1, Y1, X2, Y2;
        output [SIZE:0] distance;
        
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
            distance = ((delta/2)-1);   //Result of Square Root
            
     //   $display("X2: %d - X1: %d = xtemp: %d | xtemp*xtemp = X: %d | X + Y %d = d %d",X2, X1, xtemp, X, Y, d); 
        //   $display("d: %d | square: %d | delta: %d  | distance: %d",d, square, delta, distance);     
        end 
    endtask 





initial
    $readmemh("C:\\Users\\Tungsten\\Desktop\\College\\data_file.txt", Coordinates);    //this is NOT synthasizable (only for simulation) in hex data

    //Run independent of clock
    always @* begin

        if (NEXT_STATE == NEXT_GEN) begin                   //Pass Child Population to Population
            for(for_route = 0; for_route < Population_Size; for_route ++) begin
                for (for_city=0; for_city < NumOfCities; for_city ++) begin
                    Population[for_route][for_city] <= CHILD_Population[for_route][for_city];
                    $display("for_route = %d | for_city = %d | Population = %d |CHILD_Population = %d",for_route, for_city, Population[for_route][for_city],CHILD_Population[for_route][for_city]);
                end
            end
        end
        
        if (NEXT_STATE == SELECTION) begin
            for (i = 0; i < Population_Size; i ++) begin
                if (BEST_POP > Fitness[i] || BEST_POP == 0) begin
                    BEST_POP <= Fitness[i]; 
                end
     //           $display("Best Population Distance = %d | Current route's distance = %d",BEST_POP, Fitness[i]);
            end
        end 
/*  // this is used only for testing verification of the mutation 
        if (MUTATE_STAGE > 1) begin
            $display("route: %d | STATE : %d | City 1 = %d | City 2 = %d", route, MUTATE_STAGE, CITY1, CITY2);
            $display("Swap_1 = %d | Swap_2 = %d", MUTATE_SWAP[0] ,  MUTATE_SWAP[1] );
            $display("Mutate Values: child_1= %d | child_2 = %d", CHILD_Population[route][CITY1], CHILD_Population[route][CITY2]);
                for (city=0; city < NumOfCities; city ++) begin
                    $display("|route: %d, city: %d |Population = %d ", route, city, CHILD_Population[route][city] );
                end
            
        end  
 */
    end
    
    always @ (posedge CLK) begin
        if (!RESET) begin   // Add these during Next Gen Sequence also
            
            //init values
            INIT_STAGE <= 0;
            route <= 0;
            route_distance <= 0;
            city <= 0;
            i <= 0;
            DOUT <= 0;



            //Selection Bits
            SELECT_STAGE <=0;
            select_1 <= 0;
            select_2 <= 0;
            parent <= 0;
            selected <= 0;       //make this an absurdly big number so that it loses its value on any resonable value. 
            selected_min <= 0;
            selected_max <= 0;
            count <= 0;
            
            //Breed Init
            CHILD_STAGE <= 0;
            parents_selected <= 0;
            
            //next_gen
            temp_distance <=0;
            iterations <= 0;
            BEST_POP <= 0;
            //start GA
            NEXT_STATE <= INITIALIZE;

            //LSFR initialize
            RAND_OUT <= 8'hA;           //initial value
            TAPS <= 8'hB8;              //set a value for TAPS
        end
        
         else begin
         
         //------------------------------------------------------------------------------------------
         //LSFR: Random Number Generator
         //Note: Always run LSFR (Hardware will be permanetly allocated for this feature - not very hardware intensive)
         //------------------------------------------------------------------------------------------
         
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
        BIT6_RAND[5:0] <= RAND_OUT[6:1];
        BIT7_RAND[6:0] <= RAND_OUT[7:1];
        BIT8_RAND[7:0] <= RAND_OUT[7:0];    //Random Number 0-15

        
        case(STATE)

            INITIALIZE: begin
                //Step 1: Step up Order
                
                if (INIT_STAGE == 0) begin   //create init population
                    if (i <= NumOfCities) begin
                        Order[i] <= 2*i;
                        i <= i + 1;
                    end

                    if (i > NumOfCities) begin
                        INIT_STAGE <= INIT_STAGE + 1;
                        i <= 0;
                    end
                end //INIT_STAGE == 0

                if (INIT_STAGE == 1) begin   //Shuffle the Order of the Cities
                    Order.shuffle();
                    INIT_STAGE <= INIT_STAGE + 1;
                    city <= 0;
                end
                
                if (INIT_STAGE == 2) begin   //Shuffle the Order of the Cities
                    if (route <= Population_Size) begin
                        if (city <= NumOfCities) begin 
                            Population[route][city] <= Order[city]; 
                            city <= city + 1;
     //                        $display("route = %d | City = %d | Population[city -1]", route, Order[city], Population[route][city-1]);
                        end //city <= NumOfCities
                        if (city > NumOfCities) begin
    //                        $display("route = %d | Population[route][city-1] = %d", route, Population[route][city-1]);
                            route <= route + 1;
                            INIT_STAGE <= INIT_STAGE - 1; //Shuffle Order for next route
                        end
                    end// route <= population_Size
                    if (route > Population_Size) begin 
                        //reset selection bits
                        select_1 <= 0;
                        select_2 <= 0;
                        parent <= 0;
                        selected <= 0;       //make this an absurdly big number so that it loses its value on any resonable value. 
                        selected_min <= 0;
                        selected_max <= 0;
                        count <= 0;

                        $display("STARTING RANK_ROUTES");
                        RANK_STAGE <= 0;
                        NEXT_STATE <= RANK_ROUTES;

                        route <= 0;
                        city <= 0;
                        route_distance <= 0;

                        

                    end //route > pop size
                end //INIT_STAGE = 2
                
            end

            RANK_ROUTES: begin
                if (route <= Population_Size) begin
                    //for (city=0; city <= NumOfCities; city++) begin //calculate distance between each coordinate
                   // $display("Route %d, City%d", route, city);              

                    if (RANK_STAGE == 0) begin  //find distance 
                         
                         if(city < NumOfCities)  begin              
                            Distance(Coordinates[Population[route][city]], Coordinates[(Population[route][city])+1], Coordinates[Population[route][city +1]], Coordinates[(Population[route][city + 1]) +1], city_distance);
                          
       //                     $display("i: %d |Route %d| City: %d | Population Index: %d |X Coordinate %d | Y Coordinate %d | X2 %d | Y2 %d | %d distance",
        //                   iterations, route, city, Population[route][city], Coordinates[Population[route][city]], Coordinates[(Population[route][city])+1], Coordinates[Population[route][city +1]], Coordinates[(Population[route][city + 1]) +1], city_distance); 
                           
                            //move to next city.
                            city <= city + 1; 

                                       
                         end 
                         
                         else if(city == NumOfCities) begin
                          /* 
                            $display("Route %d| City: %d | Population %d |X1 Coordinate %d | Y1 Coordinate %d | %d city_distance",
                            route, city, Population[route][city], Coordinates[(Population[route][city])+1], Coordinates[(Population[route][city])+1], city_distance); 
                            $display("Route %d| City: %d | Population %d |X2 Coordinate %d | Y2 Coordinate %d | %d city_distance",
                            route, city, Population[route][city], Coordinates[Population[route][0]], Coordinates[(Population[route][0]) +1], city_distance);
                           */ 
                            
                            Distance(Coordinates[Population[route][city]], Coordinates[(Population[route][city])+1], Coordinates[Population[route][0]], Coordinates[(Population[route][0]) +1], city_distance);
                            //reset city and move to next route

                            RANK_STAGE <= RANK_STAGE + 1; // Move to Next Route + Record Values
                         end  

                        if (city_distance > 0)  begin   //adding this to prevent the first "X" case
                            route_distance = route_distance + city_distance;
                        end

                    end //Rank_Stage == 0

                    if (RANK_STAGE == 1) begin
                        Fitness[route] <= route_distance;   //record the total route_distance to the fitness array
                        
                        city <= 0;              //reset city counter
                        route <= route + 1;     //move to next route
                        route_distance <= 0;    //Reset Route Sum
                        
                        RANK_STAGE <= RANK_STAGE - 1;
                    end //Rank_Stage = 1
  //                       $display("Route: %d | City: %d | City Distance = %d | Route Distance = %d",route, city,
  //                       city_distance, route_distance);

                end //route <= population size

                if (route > Population_Size) begin
                    SELECT_STAGE <= 0;
                    select_1 <= 0;
                    select_2 <= 0;
                    selected <= 0;
                    Parent_Route <= 0;
                    selected_min = 0;
                    selected_max = 0;
                    NEXT_STATE <= SELECTION;
                    route <= 0;
                    city <=0;
                    for_route <= 0;
                    for_city <= 0;
                    $display("STARTING SELECTION");
                end //Route > Popsize

            end //RankRoutes End


              SELECTION: begin  
                if (parent < parent_popsize) begin              //64 Fit Parents (may not need this many...)   

                    if (SELECT_STAGE == 0) begin    //selecting parents

                        //keep selecting until both have a valid random number 
                            if (BIT8_RAND <= (Population_Size - selection_range) )begin
                                select_1 <= BIT8_RAND;
                                select_2 <=  BIT8_RAND + selection_range;  
                                SELECT_STAGE <= SELECT_STAGE + 1; 
                                       
                            end
                    end // SELECT_STAGE = 0
                    


                    if (SELECT_STAGE == 1) begin    //tournament phase for routes between min and max range
              //        $display("select_1 = %d  | select_2 = %", select_1, select_2);                         
                        if ((selected > Fitness[select_1]) || (selected == 0)) begin   //0 is default value, not an actual value               
                            selected <= Fitness[select_1];                              //pass the newest minimum value to the selected value.
                            Parent_Route <= select_1;                                   //Store the INDEX of which route that minimum fitness value belongs to.
                            
                        end
                        else begin
                            selected <= selected;
                        end 
                  /*      
                        $display("Itereation = %d | parent = %d |Distance: %d | Current_Min_Distance: %d  | Parent_Route Index = %d, select_1 = %d, select_2 = %d"
                         ,iterations,parent, Fitness[select_1], selected, Parent_Route, select_1, select_2);
                 */
                        select_1 <= select_1 + 1;
                       
                        if (select_1 == select_2) begin
                            SELECT_STAGE <= SELECT_STAGE + 1;
                        end
                    end //SELECT_STAGE <= 1

                    if (SELECT_STAGE == 2) begin    //Store Winner and then repeat process
                                
                        Fit_Parents[parent] <= Parent_Route;                                //store the index of the route in an array to be used during breeding.
                      /*              
                        $display("parent = %d |selected_min = %d |selected_max %d | Parent_Route %d | Min Route = %d| Fit_Parents[parent] %d ",
                                parent, selected_min, selected_max, Parent_Route, selected, Fit_Parents[parent-1]);
                     */
                        select_1 <= 0;
                        select_2 <= 0;
                        selected <= 0;
                       // Parent_Route <= 0;
                        selected_min = 0;
                        select_2 = 0;
                        //move to next parent selection
                        parent <= parent + 1;
                        SELECT_STAGE <= 0;

                        //Run the below test case for conclusion that this is w orking correctly.
//                                       $display("parent= %d | Min Distance Selected= %d  | Parent Index Value (PIV)= %d ",
//                                       parent, selected, Fit_Parents[parent]);
                                       
 
                    
                    end // Select_Stage == 2
                end // if (parent < parent_popsize) 
                if (parent == parent_popsize) begin
                    //initialize
                    city <= 0;
                    route <= 0;
                    i <= 0;
                    k <= 0;
                    // next state
                    NEXT_STATE <= BREED;
                    $display("STARTING BREED");
                end 
            
            end //End of Selection
      
                         
         BREED:begin   

                //Must do the below steps population_size amount of time. 
                if (route <= Population_Size) begin
                  /*  $display("route= %d | CHILD_STAGE= %d  | Parent1 = %d | Parent2 = %d ",
                                        route, CHILD_STAGE, Parent1, Parent2);
                                        */
                                        
                    //Step 0: Assign a Fit Parent Index to parent 1
                    if (CHILD_STAGE == 0) begin     
                        if ((BIT8_RAND[7:1] < parent_popsize) && (BIT8_RAND[6:0] < parent_popsize) ) begin
                            if (BIT8_RAND[7:1] != BIT8_RAND[6:0]) begin
                                Parent1 <= Fit_Parents[BIT8_RAND[7:1]];
                                Parent2 <= Fit_Parents[BIT8_RAND[6:0]];
                                CHILD_STAGE <= CHILD_STAGE + 1;
                            end
                        end
                    end
                
                    //Step 1: Assign a Fit Parent Index to parent 2
                    if (CHILD_STAGE == 1) begin
      //                      $display("Parent1 = %d | Parent2 = %d", Parent1, Parent2);
                            CHILD_STAGE <= CHILD_STAGE + 1;
                    end 
                    //Step 2: Find Cut Point
                    if (CHILD_STAGE == 2) begin   
                        if (BIT6_RAND < NumOfCities+1) begin
                            cut_point <= BIT6_RAND;
                            CHILD_STAGE <= CHILD_STAGE + 1;
                        end  
                    end 
                    // Step 3: Assign Parent 1 Genes to Child                       
                    if (CHILD_STAGE == 3) begin
                        if (i < cut_point)begin 
                        
                            Child[i] <= Population[Parent1][i];  //Assign parent1's route path's to child up to cut point
                            i <= i + 1; 
                            /*
                            $display("route = %d | Child[i-1]= %d | Population[Parent1][i]= %d  | Parent1 = %d | Parent2 = %d cutpoint = %d |i = %d ",
                                       route, Child[i-1], Population[Parent1][i], Parent1, Parent2, cut_point, i);  
                          */
                               
                        end
                        if (i == cut_point) begin
                            CHILD_STAGE <= CHILD_STAGE + 1;
                            i <= 0;
                        end 
                    end 

                    if (CHILD_STAGE > 3) begin

                        if (city <= NumOfCities) begin    //Loop through every city in parent 2 sequentially because need to check if value exists 
    
                            // Step 4: Check if 'city' is already in an the child route array
                            if (CHILD_STAGE == 4) begin
                                    
                                //check if city already is in the child's route 
                                for (j = 0; j < (cut_point); j++)begin
                                    if ( Child[j] == Population[Parent2][city] ) begin
                                        ACTIVE <= 1;   
                                    end
                                end
                                CHILD_STAGE <= CHILD_STAGE + 1;
                            end
                        end 
                    // Step 4: If it did not exist, add it. Otherwise move to next. 
                    if (CHILD_STAGE == 5) begin
                        if (!ACTIVE) begin
                           Child[cut_point+p] <= Population[Parent2][city];
                            p <= p+1;
                                  
                        end 
                        else if (ACTIVE) begin
                            ACTIVE <= 0;    //reset active alarm
                        end
                         
                        CHILD_STAGE <= CHILD_STAGE - 1; 
                        city <= city + 1;         //move to next city  
                    end
                end //if (i< NumOfCities)
                
                if (city > NumOfCities) begin
                    
                    if (k <= NumOfCities) begin
                        CHILD_Population[route][k] <= Child[k];
                        k <= k + 1;
      //                  $display("route=%d| city =%d| CHILD_Population[route][k-1] = %d |Child[k] = %d |Parent1 = %d|Parent2 = %d|cut_point = %d ",
    //                                    route, k, CHILD_Population[route][k-1],  Child[k], Population[Parent1][k], Population[Parent2][k], cut_point);
                      
                    end
                    
                    if (k > NumOfCities) begin
                        route <= route + 1;             //incremenet the route 
                        city <= 0;
                        CHILD_STAGE <= 0;               //go back to step one of making the child
                        p <= 0;                     //reset offset position
                        k <= 0;
                    end 
                    
                end
            end //if (route < population size)

            if (route > Population_Size)begin
                MUTATE_STAGE <= 0;
                CITY1 <= 0;
                CITY2 <= 0;
               
                NEXT_STATE <= MUTATE;
                route <= 0;
               $display("STARTING MUTATE");
            end

        end  //End of Breed
        
            
            MUTATE : begin  
                if (route <= Population_Size)begin
                    if (MUTATE_STAGE == 0) begin

                            if (BIT7_RAND <= 6) begin   //5% chance (can be increased)
                                //MUTATE ACTIVATED - SWAP TWO CITIES IN THE ROUTE (not 100% random - only using 6 bit values
                                CITY1 <= BIT8_RAND[5:0];
                                CITY2 <= BIT8_RAND[7:2]; 
                                MUTATE_STAGE <= MUTATE_STAGE + 1;
                            end 

                        route <= route + 1;
                    end //end Mutate_stage = 0
                    
                    if (MUTATE_STAGE == 1) begin
                            MUTATE_SWAP[0] <= CHILD_Population[route][CITY2];
                            MUTATE_SWAP[1] <= CHILD_Population[route][CITY1];
                            MUTATE_STAGE <= MUTATE_STAGE + 1;
                    end //stage = 1
                    
                    if (MUTATE_STAGE == 2) begin
                        CHILD_Population[route][CITY1] <= MUTATE_SWAP[0];
                        CHILD_Population[route][CITY2] <= MUTATE_SWAP[1];
                        
                 //       $display("route = %d |MUTATE_BIT=%d |CITY1=%d| CITY2 = %d",
                 //       route,(BIT7_RAND <= 6), CITY1, CITY2);
                        
                        MUTATE_STAGE <= MUTATE_STAGE + 1;
                        
                    end

                    if (MUTATE_STAGE == 3) begin    //adding this only so I can print out the data neatly.
                        MUTATE_STAGE <= 0;
                        route <= route + 1;
                    end
                 

                end //route <= Population Size
                
                if (route > Population_Size) begin
                    $display("NEXT_GEN");
                    
                    GEN_STAGE <= 0;
                    route <= 0;
                    city <= 0;
                    i <= 0;
                    temp_distance <= 0;
                    NEXT_STATE <= NEXT_GEN;
                end 
            end     //End Mutate
            
             NEXT_GEN: begin //Assign Mutate's Population to Population

                if (GEN_STAGE == 0) begin           //Set new Population
                    GEN_STAGE <= GEN_STAGE + 1; 
                    route <= 0;
                    city <= 0;
                   
 
                end //GEN = 0
                
                if (GEN_STAGE == 1) begin   //use this sectrion for troubleshooting if needed
                        GEN_STAGE <= GEN_STAGE + 1;
                     
                end //GEN = 0

                                
                if (GEN_STAGE == 2) begin   //Store Best _ Population for the iteration in an array.
                    BEST_ARRAY[iterations] <= BEST_POP;
                    GEN_STAGE <= GEN_STAGE + 1;
                end //Gen Stage 2
                                      
                if (GEN_STAGE == 3) begin
                    $display("Minimum Route Available ",BEST_POP);
                    DOUT <= 1;
                    //RESET VALUES
                    route <= 0;
                    route_distance <= 0;
                    city <= 0;
        
                    //LSFR initialize
                    RAND_OUT <= 8'hA + iterations;           //initial value
                    TAPS <= 8'hB8;              //set a value for TAPS
        
                    //Selection Bits
                    select_1 <= 0;
                    select_2 <= 0;
                    parent <= 0;
                    selected <= 0;     
                    selected_min <= 0;
                    selected_max <= 0;
                    count <= 0;
                    BEST_POP <=0;
                    //Breed Init
                    CHILD_STAGE <= 0;
                    parents_selected <= 0;
                    iterations <= iterations + 1;
                    GEN_STAGE <= GEN_STAGE + 1;
                end // GEN_STAGE 3
                
                if (GEN_STAGE == 4) begin     
                    DOUT <= 0;                    
                    if (iterations >= total_iterations ) 
                        NEXT_STATE <= DONE;
                    else
                        NEXT_STATE <= RANK_ROUTES;
                        $display("Ranking Children Population");
                end //Genn stage = 4
            end //END NEXTGEN
             
                
            DONE: begin

            end
                                
            default: begin
            end  
        endcase
        
        STATE <= NEXT_STATE;
    end 
    
endmodule