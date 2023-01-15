`timescale 1ns/1ns
import my_pkg ::*;
module Genetic_Algorithm(CLK, RESET);

    input CLK;
    input RESET;

    //INITIALIZE IO
    reg [SIZE:0] COORDINATES [0: (NumOfCities*2)-1];         //read cities x and y each city: EXAMPLE (10 CITIES = 0:21 = 20 CITIES)
    integer Index[0 : NumOfCities - 1];                            //Represents the city coordinate - as read from file
    integer RouteIndex[ 0: Population_Size - 1];
    reg [SIZE - 1:0] POPULATION [0: (NumOfCities * Population_Size)-1];
    
    reg [SIZE - 1:0] distance_arr [0: (NumOfCities * Population_Size)-1];  //using this for testing purposes.
     
    integer i, j, city, route, count, temp1, temp2;
    
    //State_2 I/O
    reg [SIZE - 1:0] city_distance;

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

    //state_4 I/O (selection)\
    integer SELECTION_ARR [0: Population_Size-1];
    reg [7:0] pick, selected1, selected2, selected3, selected4;
    
    initial begin
        //not synthsizable but make sure that this can be applied to the project folder, not personal computer
        $readmemh("C:\\Users\\Tungsten\\Desktop\\College\\data_file.txt", COORDINATES);  
        NEXT_STATE <= STATE_1;
        

        
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
        
     end 

    always @ (posedge CLK)
    begin

        if (!RESET) 
        begin
        
        /*
        //LSFR: Random Number Generator

        RAND_OUT <= RAND_OUT >> 1;
        RAND_OUT[7] <= RAND_OUT[0] ^
                             ((TAPS[6]) ? RAND_OUT[1] : 0) ^
                             ((TAPS[5]) ? RAND_OUT[2] : 0) ^
                             ((TAPS[4]) ? RAND_OUT[3] : 0) ^
                             ((TAPS[3]) ? RAND_OUT[4] : 0) ^
                             ((TAPS[2]) ? RAND_OUT[5] : 0) ^
                             ((TAPS[1]) ? RAND_OUT[6] : 0) ^
                             ((TAPS[0]) ? RAND_OUT[7] : 0);
        
        */
            case (STATE)
                STATE_1: begin
                        
                    for(i=0; i<=NumOfCities; i++)
                    begin
                        Index[i] <= 2*i;
                    end
                    
                    for (i=0; i<= Population_Size; i++)
                    begin
                        RouteIndex[i] = i;
                    end 
                    
                    for (route=0; route <= Population_Size; route++) 
                    begin
                        Index.shuffle();
                        for (city=0; city <= NumOfCities; city++)  
                            POPULATION[((route*NumOfCities) + city)] <= Index[city];
                    end 
                    NEXT_STATE <= STATE_2;
                end //End of Initialization/State_1

                STATE_2: begin
                    
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
                
                STATE_3: begin

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

                STATE_4: begin
                    for (i = 0; i < ElitismSize; i++) 
                        begin
                            SELECTION_ARR[i] <= RouteIndex[i];

                        end 

                    NEXT_STATE <= STATE_5;
                    pick <= BIT4_RAND;
                    selected1 <= BIT10_RAND[9:6]; 
                    selected2 <= BIT10_RAND[8:5];
                    selected3 <= BIT10_RAND[7:4];
                    selected4 <= BIT10_RAND[6:3];
                end      

                STATE_5: begin      //CLK sensitive
                    if (i < Population_Size)
                    begin

                        pick <= BIT4_RAND;
                        selected1 <= BIT10_RAND[9:6]; 
                        selected2 <= BIT10_RAND[8:5];
                        selected3 <= BIT10_RAND[7:4];
                        selected4 <= BIT10_RAND[6:3];

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
                    else if (i > Population_Size - ElitismSize) 
                        NEXT_STATE <= STATE_6;
                        i <= ElitismSize - 1;
                        MUTATION <= 0;

                        CHANCE <= BIT_8RAND
                end 

            endcase 
        end
        STATE <= NEXT_STATE;
    end 
    
    
endmodule 


