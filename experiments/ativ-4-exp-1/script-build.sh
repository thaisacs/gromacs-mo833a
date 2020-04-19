#!/bin/bash
#Author : Thais Camacho

set OMP_NUM_THREADS=1

DIR=~/Dev/gromacs-mo833a

check_params() {
  if [ ! "$1" = "1" ]; then
    echo "invalid parameter[s]"
    exit 0
  fi
}

check_params $#

PARAM=$1
echo $PARAM

cd $DIR
mkdir -p build
cd build

if [[ "$PARAM" == "Release" ]]; then
  mkdir release
  cd release
  echo "-- release mode"
  cmake ../.. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_BUILD_TYPE=Release
elif [[ "$PARAM" == "Debug" ]]; then
  mkdir debug
  cd debug
  echo "-- debug mode"
  cmake ../.. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_BUILD_TYPE=Debug
else
  exit 0
fi

make -j 3
