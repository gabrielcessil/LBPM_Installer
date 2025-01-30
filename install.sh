#!/bin/bash

echo -e "Download zips (do not extract):\n  openmpi-3.1.6\n  cmake-3.26.0\n  zlib-1.2.11\n  hdf5-1.8.12\n  silo-4.10.2\nThen, press any key to start..."
read -p ""

sudo apt install gfortran

mkdir mpi zlib hdf5 silo

export MPI_DIR=$(pwd)/mpi
export LBPM_ZLIB_DIR=$(pwd)/zlib
export LBPM_HDF5_DIR=$(pwd)/hdf5
export LBPM_SILO_DIR=$(pwd)/silo
echo $MPI_DIR
echo $LBPM_ZLIB_DIR
echo $LBPM_HDF5_DIR
echo $LBPM_SILO_DIR

tar -xvzf openmpi-3.1.6.tar.gz
cd openmpi-3.1.6
./configure --prefix=$MPI_DIR
make
sudo make install

cd ..

tar -xvzf cmake-3.26.0.tar.gz
cd cmake-3.26.0
sudo apt-get install libgl1-mesa-dev
./bootstrap
./bootstrap --prefix=/usr/local
make

sudo apt install gcd $LBPM_DIR

sudo make install

cd ..

tar -xzvf zlib-1.2.11.tar.gz
tar -xzvf hdf5-1.8.12.tar.gz
tar -xzvf silo-4.10.2.tar.gz

cd zlib-1.2.11

./configure --prefix=$LBPM_ZLIB_DIR && make && make install

cd ../hdf5-1.8.12

CC=$MPI_DIR/bin/mpicc  CXX=$MPI_DIR/bin/mpicxx CXXFLAGS="-fPIC -O3 -std=c++14" \
./configure --prefix=$LBPM_HDF5_DIR --enable-parallel --enable-shared --with-zlib=$LBPM_ZLIB_DIR
 make && make install


sudo apt-get install zlib1g-dev

cd ../silo-4.10.2


CC=$MPI_DIR/bin/mpicc  CXX=$MPI_DIR/bin/mpicxx CXXFLAGS="-fPIC -O3 -std=c++14" \
./configure --prefix=$LBPM_SILO_DIR -with-hdf5=$LBPM_HDF5_DIR/include,$LBPM_HDF5_DIR/lib --enable-static
 make && make install

cd ..

# prosseguir


mkdir LBPM_source LBPM_dir

export LBPM_SOURCE=$(pwd)/LBPM_source
export LBPM_DIR=$(pwd)/LBPM_dir
echo $LBPM_SOURCE
echo $LBPM_DIR


# DOWNLOAD LBPM, THEN EXTRACT AT LBPM_SOURCE FOLDER.
echo -e "\n\n\n\n\n Cloning github repository, make sure you have it on your machine.\n\n Then press any key to continue ..."
read -p ""

# prosseguir


cd $LBPM_SOURCE
git clone -b master https://github.com/OPM/LBPM
mv LBPM/* LBPM/.* .
rmdir LBPM
cd ..

cd $LBPM_DIR

# INCLUDE {#include "IO/silo.h"} on LBPM_source/IO/Reader.cpp headers
echo -e "\n\n\n\n\n Please, write {#include \"IO/silo.h\"} on LBPM_source/IO/Reader.cpp headers.\n\n Then press any key to continue: ..."
read -p ""

# INCLUDE {#include <cstdint>} on LBPM_source/tests/DataAggregator.cpp headers
echo -e "\n\n\n\n\n Please, write {#include <cstdint>} on LBPM_source/tests/DataAggregator.cpp headers.\n\n Then press any key to continue: ..."
read -p ""

cmake                                           \
    -D CMAKE_BUILD_TYPE:STRING=Release          \
    -D CMAKE_C_COMPILER:PATH=mpicc              \
    -D CMAKE_CXX_COMPILER:PATH=mpicxx           \
    -D CMAKE_C_FLAGS="-fPIC"                    \
    -D CMAKE_CXX_FLAGS="-fPIC"                  \
    -D CMAKE_CXX_STD=14                         \
    -D USE_TIMER=0                              \
        -D TIMER_DIRECTORY=$LBPM_TIMER_DIR     \
    -D USE_NETCDF=0                             \
        -D NETCDF_DIRECTORY=$LBPM_NETCDF_DIR   \
    -D USE_SILO=1                               \
       -D HDF5_DIRECTORY=$LBPM_HDF5_DIR         \
       -D SILO_DIRECTORY=$LBPM_SILO_DIR         \
    -D USE_CUDA=0                               \
    $LBPM_SOURCE

make -j4

make install

ctest # Falhar alguns testes eh normal

echo -e "\n\nFinished. Some tests may fail, but it should still be usable. \n\n"

