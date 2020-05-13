BIN='../../../build/bin/gmx'

cd experiment
/usr/bin/time -p $BIN mdrun -nt 1 -v -deffnm em >> output.txt
