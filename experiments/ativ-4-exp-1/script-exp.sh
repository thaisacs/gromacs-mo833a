#!/bin/bash
#Author : Thais Camacho

BIN='../../../build/release/bin/gmx'

check_param $#

FILE_NAME=$1

cd experiment
#/usr/bin/time -av -o output.txt -p $BIN mdrun -v -deffnm em
/usr/bin/time -av -o output-perf.txt -p sudo perf record $BIN mdrun -v -deffnm em
#/usr/bin/time -av -o output-valdrind.txt -p valgrind --tool=callgrind $BIN mdrun -v -deffnm em
