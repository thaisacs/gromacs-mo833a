#!/bin/bash
#Author : Thais Camacho

BIN='../../../build/release/bin/gmx'

check_param $#

FILE_NAME=$1

cd experiment

#/usr/bin/time -o output-4t.txt -p $BIN mdrun -v -deffnm em
#/usr/bin/time -av -o output-perf.txt -p sudo perf record $BIN mdrun -v -deffnm em
#/usr/bin/time -av -o output-valdrind.txt -p valgrind --tool=callgrind $BIN mdrun -v -deffnm em

/usr/bin/time -o output.txt -p $BIN mdrun -nt 1 -v -deffnm em
/usr/bin/time -o output-perf.txt -p sudo perf record $BIN mdrun -nt 1 -v -deffnm em
/usr/bin/time -o output-valdrind.txt -p valgrind --tool=callgrind $BIN mdrun -nt 1 -v -deffnm em
