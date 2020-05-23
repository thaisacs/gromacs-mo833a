import csv
import matplotlib.pyplot

x = []

def read_output(filename):
    paramount_iteration = []
    app_time = []

    with open(filename, 'r') as file:
        reader = csv.reader(file, delimiter = ',')
        for row in reader:
            app_time.append(float(row[2]))
            paramount_iteration.append(float(row[3]))

    return paramount_iteration

def get_mean(array, amount):
    mean = []

    for i in range(0, 10):
        for j in range(0, 2*amount):
            if(j == 0):
                mean.append(array[i+j])
            else:
                mean[i] = mean[i] + array[i+j]
        mean[i] = mean[i]/(2*amount)
        x.append(i+1)

    return mean

def get_axisx():
    x = []

    for i in range(1, 11):
        x.append(i)

    return x

cluster2 = get_mean(read_output("cluster2.csv"), 2)
cluster4 = get_mean(read_output("cluster4.csv"), 4)
cluster8 = get_mean(read_output("cluster8.csv"), 8)

print(cluster8)
print(sum(cluster8)/10)

x = get_axisx()

matplotlib.pyplot.plot(x, cluster2, label="2x")
matplotlib.pyplot.plot(x, cluster4, label="4x")
matplotlib.pyplot.plot(x, cluster8, label="8x")
matplotlib.pyplot.xlabel('Iteração')
matplotlib.pyplot.ylabel('Tempo da Paramount Iteration (s)')
matplotlib.pyplot.legend(loc="upper left")

matplotlib.pyplot.savefig('result.png')

