BIN='../../../build/bin/gmx'

cd experiment
/usr/bin/time $BIN mdrun -v -deffnm em >> output.csv
