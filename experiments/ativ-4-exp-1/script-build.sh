#!/bin/bash
#Author : Thais Camacho

DIR=~/Dev/gromacs-mo833a

check_params() {
  if [ ! "$1" = "1" ]; then
    echo "invalid parameter[s]"
    exit 0
  fi
}

check_params $#

PARAM=$1

cd $DIR
mkdir -p build
cd build

if [[ "$PARAM" == "Release" ]]; then
  echo "-- release mode"
  cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_BUILD_TYPE=Release
elif [[ "$PARAM" == "Debug" ]]; then
  echo "-- debug mode"
  cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_BUILD_TYPE=Debug
elif [[ "$PARAM" == "No-Parallel" ]]; then
  echo "-- no-openmp mode"
  cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_BUILD_TYPE=Release -DGMX_THREAD_MPI=OFF -DGMX_MPI=OFF -DGMX_OPENMP=OFF -DGMX_GPU=OFF
else
  exit 0
fi

make -j 3
