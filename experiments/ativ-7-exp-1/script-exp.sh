#!/bin/sh

cd experiment
mpirun -n 4 --hostfile ../hostfile ../../../build/bin/gmx_mpi mdrun -v -deffnm em 1> gmx.out 2> gmx.err
