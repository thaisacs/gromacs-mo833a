cd experiment
<<<<<<< HEAD
#mpirun -n 1 ../../../build/bin/gmx_mpi mdrun -v -deffnm em
mpirun -n 4 --hostfile ../hostfile ../../../build/bin/gmx_mpi mdrun -v -deffnm em
=======
mpirun -n 4 --hostfile hostfile ../../../build/bin/gmx_mpi mdrun -v -deffnm em
>>>>>>> 7f556594eff93158d895ac410ac194b0a9d1dac4
