BIN='../../../build/bin/gmx'

cd experiment
$BIN mdrun -nt 1 -v -deffnm em >> output.txt
