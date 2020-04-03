#!/bin/bash
#Author : Thais Camacho

BIN='../../../build/bin/gmx'

check_param() {
  if [ ! "$1" = "1" ]; then
    echo "invalid parameter[s]"
    exit 0
  fi
}

check_param $#

FILE_NAME=$1

cd experiment
for i in `seq 1 99`; do
  $BIN mdrun -v -deffnm em >> output.txt
done
cut -d " " -f 5 output.txt > $FILE_NAME
