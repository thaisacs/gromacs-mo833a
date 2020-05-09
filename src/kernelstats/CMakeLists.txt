add_library(kernelstats kernel_stats.cpp)
install(TARGETS kernelstats EXPORT kernelstats-targets DESTINATION lib)
