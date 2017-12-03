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
sum_weight = 0
sum_volume = 0


def fitness(individual, data):
    fitness = 0
    s_weight = 0
    s_volume = 0
    for (selected, [weight, volume, profit]) in zip(individual, data):
        if selected:
            if s_weight + weight > carrying or s_volume + volume > capacity:
                fitness = 0
                break
            s_weight += weight
            s_volume += volume
            fitness += profit
    return fitness


def items_decode(codes):
    result = []
    for (i, selected) in zip(range(1, len(codes)), codes):
        if selected:
            result.append(i)
    return result


def calculate_dimensions(individual, data):
    global sum_weight
    global sum_volume
    sum_weight = 0
    sum_volume = 0
    for (selected, [weight, volume, _]) in zip(individual, data):
        if selected:
            sum_weight += weight
            sum_volume += volume


ga.fitness_function = fitness
ga.run()
best_individual = ga.best_individual()
calculate_dimensions(best_individual[1], items)
print "value: " + str(int(best_individual[0]))
print "weight " + str(int(sum_weight))
print "volume " + str(int(sum_volume))
print "items: " + str(items_decode(best_individual[1]))

resultFile = open("result.txt", "w")
resultFile.write(json.dumps({"value": int(best_individual[0]), "weight": int(sum_weight), "volume": int(sum_volume), "items": items_decode(best_individual[1])}))
