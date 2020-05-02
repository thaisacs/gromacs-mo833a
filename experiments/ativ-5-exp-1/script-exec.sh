cd experiment
#mpirun -n 1 ../../../build/bin/gmx_mpi mdrun -v -deffnm em
mpirun -n 4 --hostfile ../hostfile ../../../build/bin/gmx_mpi mdrun -v -deffnm em
