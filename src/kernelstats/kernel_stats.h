#include <sys/time.h>

namespace gmx {
  class KernelStats {
    int iteration = 0;
    double init_time;
    double begin_time;

    double get_time();
  public:
    void init_timestep();
    void begin_timestep();
    void end_timestep();
    int get_iteration();
  };
}

gmx::KernelStats KS;
