#include <sys/time.h>
#include <memory>

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
  };
}

std::unique_ptr<gmx::KernelStats> KS = std::make_unique<gmx::KernelStats>();
