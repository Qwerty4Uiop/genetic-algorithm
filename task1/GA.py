from pyeasyga import pyeasyga
import json

sourceFile = open("25.txt", 'r')
items = []
for line in sourceFile:
    items.append(map(float, line.split()))
carrying = items[0][0]
capacity = items[0][1]
del items[0]
ga = pyeasyga.GeneticAlgorithm(items)
sumWeight = 0
sumVolume = 0


def fitness(individual, data):
    fitness = 0
    global sumWeight
    global sumVolume
    sumWeight = 0
    sumVolume = 0
    for (selected, [weight, volume, profit]) in zip(individual, data):
        if selected:
            if sumWeight + weight > carrying or sumVolume + volume > capacity:
                fitness = 0
                break
            sumWeight += weight
            sumVolume += volume
            fitness += profit
    return fitness


def itemsDecode(codes):
    result = []
    for (i, selected) in zip(range(1, len(codes)), codes):
        if selected:
            result.append(i)
    return result


ga.fitness_function = fitness
ga.run()
bestIndividual = ga.best_individual()
print "value: " + str(int(bestIndividual[0]))
print "weight " + str(int(sumWeight))
print "volume " + str(int(sumVolume))
print "items: " + str(itemsDecode(bestIndividual[1]))

resultFile = open("result.txt", "w")
resultFile.write(json.dumps({"value": int(bestIndividual[0]), "weight": int(sumWeight), "volume": int(sumVolume), "items": itemsDecode(bestIndividual[1])}))
