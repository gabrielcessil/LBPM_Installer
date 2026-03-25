#!/bin/bash

echo -e "Press any key to start..."
read -p ""

DEFAULT_REPO="https://github.com/poro-labcc/lbpm/"
DEFAULT_BRANCH="master"

sudo apt install gfortran

mkdir mpi zlib hdf5 silo

export MPI_DIR=$(pwd)/mpi
export LBPM_ZLIB_DIR=$(pwd)/zlib
export LBPM_HDF5_DIR=$(pwd)/hdf5
export LBPM_SILO_DIR=$(pwd)/silo



echo -e "\n\n Please, make sure the following paths are correctly set in the installation folder. Then, press any key to continue..."
echo $MPI_DIR
echo $LBPM_ZLIB_DIR
echo $LBPM_HDF5_DIR
echo $LBPM_SILO_DIR
read -p ""

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



mkdir LBPM_source LBPM_dir

export LBPM_SOURCE=$(pwd)/LBPM_source
export LBPM_DIR=$(pwd)/LBPM_dir
echo $LBPM_SOURCE
echo $LBPM_DIR


# DOWNLOAD LBPM, THEN EXTRACT AT LBPM_SOURCE FOLDER.
echo -e "\n\n\n\n\n Cloning github repository. Make sure you have git properly set in your machine. Consider using 'apt-get install git' ... \n\n Press any key to continue ..."
read -p ""


cd $LBPM_SOURCE

echo -e "\n\nEnter the GitHub repository link"
read -p "[Press Enter for Default: $DEFAULT_REPO]: " USER_REPO
USER_REPO=$(echo "$USER_REPO" | xargs | tr -d '"')
REPO_TO_CLONE=${USER_REPO:-$DEFAULT_REPO}
echo -e "\nCloning from: $REPO_TO_CLONE ...\n"


read -p "Enter the branch name [Leave empty to clone full repository]: " USER_BRANCH
USER_BRANCH=$(echo "$USER_BRANCH" | xargs)

if [ -z "$USER_BRANCH" ]; then
    echo -e "\nCloning full repository (all branches) from $REPO_TO_CLONE ...\n"
    git clone "$REPO_TO_CLONE" .
else
    echo -e "\nCloning branch: $USER_BRANCH from $REPO_TO_CLONE ...\n"
    git clone -b "$USER_BRANCH" --single-branch "$REPO_TO_CLONE" .
fi

rmdir LBPM
cd ..

# INCLUDE {#include "IO/silo.h"} on LBPM_source/IO/Reader.cpp headers
echo -e "\n\n\n\n\n Please, write {#include \"IO/silo.h\"} on LBPM_source/IO/Reader.cpp headers.\n\n Then press any key to continue: ..."
read -p ""

# INCLUDE {#include <cstdint>} on LBPM_source/tests/DataAggregator.cpp headers
echo -e "\n\n\n\n\n Please, write {#include <cstdint>} on LBPM_source/tests/DataAggregator.cpp headers.\n\n Then press any key to continue: ..."
read -p ""

cd $LBPM_DIR

cmake                                           \
    -D CMAKE_BUILD_TYPE:STRING=Release          \
    -D CMAKE_C_COMPILER:PATH=$MPI_DIR/bin/mpicc              \
    -D CMAKE_CXX_COMPILER:PATH=$MPI_DIR/bin/mpicxx           \
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

ctest

echo -e "\n\nFinished. Some tests may fail due the development stage, but it should still work for general porpouse applications. \n\n"

