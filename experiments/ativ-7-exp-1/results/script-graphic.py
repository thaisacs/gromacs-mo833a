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

cluster2 = read_output("cluster2.csv")
cluster4 = read_output("cluster4.csv")
cluster8 = read_output("cluster8.csv")

x = get_axisx()

matplotlib.pyplot.plot(x, cluster2, label="2x")
matplotlib.pyplot.plot(x, cluster4, label="4x")
matplotlib.pyplot.plot(x, cluster8, label="8x")
matplotlib.pyplot.xlabel('Iteração')
matplotlib.pyplot.ylabel('Tempo da Paramount Iteration (s)')
matplotlib.pyplot.legend(loc="upper right")

matplotlib.pyplot.savefig('result.png')

