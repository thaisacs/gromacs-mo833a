import csv
import matplotlib.pyplot

x = []
paramount_iteration = []
app_time = []

with open('experiment/output.csv', 'r') as file:
    reader = csv.reader(file, delimiter = ' ')
    for row in reader:
        x.append(int(row[0]))
        app_time.append(float(row[1]))
        paramount_iteration.append(float(row[2]))

matplotlib.pyplot.plot(x, paramount_iteration)

print(app_time[len(app_time)-1])
print(sum(paramount_iteration))

matplotlib.pyplot.show()
