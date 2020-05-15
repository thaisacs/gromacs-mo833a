#include "kernel_stats.h"
#include <iostream>

using namespace gmx;

double KernelStats::get_time() {
    struct timeval tp;
    struct timezone tzp;
    gettimeofday(&tp,&tzp);
    return ((double) tp.tv_sec + (double) tp.tv_usec * 1.e-6 );
}

void KernelStats::init_timestep() {
  init_time = get_time();
}

void KernelStats::end_timestep() {
  double end_time = get_time();
  std::cout << "Iteration," << iteration << "," << end_time - init_time << ","
    << end_time - begin_time << std::endl;
}

void KernelStats::begin_timestep() {
  if(iteration == 0) {
    double current_time = get_time();
    std::cout << "Init time," << current_time - init_time << std::endl;
  }
  iteration++;
  begin_time = get_time();
}

int KernelStats::get_iteration() {
  return iteration;
}
