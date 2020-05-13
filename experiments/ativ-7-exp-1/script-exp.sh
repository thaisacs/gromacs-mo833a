cd experiment
mpirun -n 2 --hostfile ../hostfile ../../../build/bin/gmx_mpi mdrun -v -deffnm em
