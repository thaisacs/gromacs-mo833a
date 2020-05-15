#!/bin/sh

cd experiment
mpirun -n 2 --hostfile ../hostfile2 ../../../build/bin/gmx_mpi mdrun -v -deffnm em
