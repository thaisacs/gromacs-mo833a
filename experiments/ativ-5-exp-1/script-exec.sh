cd experiment
mpirun -n 4 --hostfile ../hostfile ../../../build/bin/gmx_mpi mdrun -v -deffnm em
