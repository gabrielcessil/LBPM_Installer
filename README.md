# LBPM_Installer

LBPM_Installer is a simple script to install LBPM (Lattice Boltzmann for Porous Media) in Linux Environment

The LBPM original source code: https://github.com/OPM/LBPM

The installation documents: https://lbpm-sim.org/



To install LPBM:

0) The LBPM code currently have a nativa error, to correct it: 
 - Please, write {#include \"IO/silo.h\"} on LBPM_source/IO/Reader.cpp headers;
 - Please, write {#include <cstdint>} on LBPM_source/tests/DataAggregator.cpp headers.
1) Open terminal and navigate until this folder location
2) Run this command: chmod +x install.sh
3) Then, run this command: ./install.sh
4) On some points, the linux bash will wait for entries to continue. Read and follow to avoid native errors. The bash will continue with any pressed key, caution on CTRL+C that may be considered as input (use mouse click).
