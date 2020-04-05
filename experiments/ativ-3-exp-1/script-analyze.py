import sys
import seaborn as sns
import numpy as np
from pandas import DataFrame, Series
from matplotlib import pyplot as plt

sns.set(color_codes=True)

def cmd_line():
    if(len(sys.argv) < 3):
        print('invalid parameter(s)')
        sys.exit(0)

    op = 0

    try:
        op = int(sys.argv[2])
    except ValueError:
        print('second param need be an integer')
        sys.exit(0)

    return sys.argv[1], op

def linear_regression(file_path):
    y_axis = np.genfromtxt(file_path, delimiter='\n')
    x_axis = np.arange(1, len(y_axis)+1)

    data_merge = {'Execução': x_axis, 'Tempo de Execução (s)': y_axis}
    data_frame = DataFrame(data=data_merge)

    sns.lmplot(x='Execução', y='Tempo de Execução (s)',
               data=data_frame, ci=95);
    plt.savefig('lr.png')

def histogram(file_path):
    values = np.genfromtxt(file_path, delimiter='\n')
    values = Series(values, name="Tempo de Execução (s)")
    sns.distplot(values, hist=True);
    plt.savefig('hist.png')

def main():
    file_path, op = cmd_line()

    if(op == 1):
        linear_regression(file_path)
    elif(op == 2):
        histogram(file_path)

main()
