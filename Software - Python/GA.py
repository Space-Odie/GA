import numpy as np
import random
import operator
import pandas as pd
import matplotlib.pyplot as plt

#Create a City class to create and handle cities. X,Y coordinates
class City:
    def __init__(self, x, y): #int: x, int: y):-> x,y cooridnates
        self.x = x
        self.y = y
    
    def distance(self, city):    #-> distance       
        xDis = abs(self.x - city.x)
        yDis = abs(self.y - city.y)
        distance = np.sqrt((xDis ** 2) + (yDis ** 2)) #Pythagorean theorem to find distance
        return distance
    
    def __repr__(self):                 #Output cities as coordinates ->string
        return "(" + str(self.x) + "," + str(self.y) + ")"  

#fitness as the inverse of the route distance. So Larger fitness score is better.
# Rule #2 must end at location started at 
class Fitness:
    def __init__(self, route):
        self.route = route
        self.distance = 0
        self.fitness= 0.0
    
    def routeDistance(self):
        if self.distance ==0:
            pathDistance = 0
            for i in range(0, len(self.route)):
                fromCity = self.route[i]
                toCity = None
                if i + 1 < len(self.route):
                    toCity = self.route[i + 1]
                else:
                    toCity = self.route[0]
                pathDistance += fromCity.distance(toCity)
            self.distance = pathDistance
        return self.distance
    
    def routeFitness(self):
        if self.fitness == 0:
            self.fitness = 1 / float(self.routeDistance())
        return self.fitness

#Randomly Create A route that satisfies the conditions 
def createRoute(cityList):  
    route = random.sample(cityList, len(cityList))
  #  print(f'Route: {route}')
    return route

#Use teh Create Route Function to create a POPULATION
def initialPopulation(popSize, cityList):
    population = []
    for i in range(0, popSize):
        population.append(createRoute(cityList))
     #   print(f"Initial Population: {population}")
    return population

#Rank the fitness of each route using an ordered list with RouteID + fitness score
def rankRoutes(population):
    fitnessResults = {}
    for i in range(0,len(population)):
        fitnessResults[i] = Fitness(population[i]).routeFitness()
    return sorted(fitnessResults.items(), key = operator.itemgetter(1), reverse = True)


#implement Fitness proportionate selection
#Select randomly with probability based on fitness scale
def selection(popRanked, eliteSize):                   
    selectionResults = []
    df = pd.DataFrame(np.array(popRanked), columns=["Index","Fitness"])
    df['cum_sum'] = df.Fitness.cumsum()
    df['cum_perc'] = 100*df.cum_sum/df.Fitness.sum()
    
    #implement elitism by keeping best performing route
    for i in range(0, eliteSize):                       
        selectionResults.append(popRanked[i][0])
    for i in range(0, len(popRanked) - eliteSize):
        pick = 100*random.random()
        for i in range(0, len(popRanked)):
            if pick <= df.iat[i,3]:
                selectionResults.append(popRanked[i][0])
                break
    return selectionResults

#Create a mating pool with the selected IDs (above function)
def matingPool(population, selectionResults):
    matingpool = []
    for i in range(0, len(selectionResults)):
        index = selectionResults[i]
        matingpool.append(population[index])
    return matingpool


#Breeding the matingPool using crossover by splicing the selected population together
#CONSTRAINT: Each location must only be located in the pool one time - ordered crossover is used    
# Ordered crossover:  randomly select a subset of the first parent string 
# then fill the remainder of the route with the genes from the second parent 
# in the order in which they appear, without duplicating any genes 
def breed(parent1, parent2):
    child = []
    childP1 = []
    childP2 = []
    
    geneA = int(random.random() * len(parent1))
    geneB = int(random.random() * len(parent1))
    
    startGene = min(geneA, geneB)
    endGene = max(geneA, geneB)

    for i in range(startGene, endGene):
        childP1.append(parent1[i])
        
    childP2 = [item for item in parent2 if item not in childP1]

    child = childP1 + childP2
    return child

#Use the above breed function to breed an entire population
def breedPopulation(matingpool, eliteSize):
    children = []
    length = len(matingpool) - eliteSize
    pool = random.sample(matingpool, len(matingpool))

    for i in range(0,eliteSize):            #breed the selected elite case
        children.append(matingpool[i])
    
    for i in range(0, length):              #breed remaining selected cases
        child = breed(pool[i], pool[len(matingpool)-i-1])
        children.append(child)
    return children

#MUTATE - avoid local convergence by changing a city with another
#RULE: Can't have the same city twice - using swap mutation instead. 
def mutate(individual, mutationRate):
    for swapped in range(len(individual)):
        if(random.random() < mutationRate):
            swapWith = int(random.random() * len(individual))
            
            city1 = individual[swapped]
            city2 = individual[swapWith]
            
            individual[swapped] = city2
            individual[swapWith] = city1
    return individual

#Use the above function to mutate the entire population
def mutatePopulation(population, mutationRate):
    mutatedPop = []
    
    for ind in range(0, len(population)):
        mutatedInd = mutate(population[ind], mutationRate)
        mutatedPop.append(mutatedInd)
    return mutatedPop

def nextGeneration(currentGen, eliteSize, mutationRate):
    popRanked = rankRoutes(currentGen)                      #rank the routes in the current generation 
    selectionResults = selection(popRanked, eliteSize)      #determine our potential parents 
    matingpool = matingPool(currentGen, selectionResults)   #create the mating pool
    children = breedPopulation(matingpool, eliteSize)       #create our new generation
    nextGeneration = mutatePopulation(children, mutationRate)   # applying mutation
    return nextGeneration

#Create initial Population and loop through desired generations
def geneticAlgorithm(population, popSize, eliteSize, mutationRate, generations):
    pop = initialPopulation(popSize, population)
  #  print("Initial distance: " + str(1 / rankRoutes(pop)[0][1]))    #capture initial distance
    
    #run the loop for generation # of times
    #Create a condition that stops if solution is found? 
    for i in range(0, generations):                         
        pop = nextGeneration(pop, eliteSize, mutationRate)
    
    print("Final distance: " + str(1 / rankRoutes(pop)[0][1]))
    bestRouteIndex = rankRoutes(pop)[0][0]
    bestRoute = pop[bestRouteIndex]
    return bestRoute
    
def geneticAlgorithmPlot(population, popSize, eliteSize, mutationRate, generations):
    pop = initialPopulation(popSize, population)
    progress = []
    progress.append(1 / rankRoutes(pop)[0][1])
    
    for i in range(0, generations):
        pop = nextGeneration(pop, eliteSize, mutationRate)
        progress.append(1 / rankRoutes(pop)[0][1])
    
    plt.plot(progress)
    plt.title('Mutation @ 5%')
    plt.ylabel('Distance')
    plt.xlabel('Generation')
    plt.show()



cityList = []

#Create 25 Cities: this value can be changed for more 
for i in range(0,25):
    cityList.append(City(x=int(random.random() * 200), y=int(random.random() * 200)))
    #print(repr(City(x=int(random.random() * 200), y=int(random.random() * 200))))


#Start the program with constraint parameters below

#Plot
geneticAlgorithmPlot(population=cityList, popSize=100, eliteSize=20, mutationRate=0.01, generations=500)
#just output
#geneticAlgorithm(population=cityList, popSize=100, eliteSize=20, mutationRate=0.01, generations=500)

