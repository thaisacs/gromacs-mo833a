BIN='../../../build/bin/gmx'

cd experiment
/usr/bin/time -p $BIN mdrun -v -deffnm em >> output.txt
