#!/bin/bash

apt-get update && apt-get -y install cmake wget bzip2

GEOS_VERSION=$(wget -qO- "https://api.github.com/repos/libgeos/geos/git/refs/tags" | grep -oP "(?<=\"ref\":\s\"refs/tags/)\d+\.\d+\.\d+" | tail -n -1)

wget https://download.osgeo.org/geos/geos-"${GEOS_VERSION}".tar.bz2
bzip2 -d geos-*bz2
tar xf geos*tar
rm geos*tar
cd geos*
mkdir build
cd build
cmake ..
cmake --build . --parallel --target install
ldconfig

