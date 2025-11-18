# GDAL install/update utilities

This repository contains scripts to support the installation of GDAL (Geospatial Data Abstraction Library) on Ubuntu. It is adapted from this excellent [gist](https://gist.github.com/samapriya/412babdfd3530c2766acb9d603ed1bb9) by [@samapriya](https://gist.github.com/samapriya). 

Things I've added include a makefile for slightly simpler usage. Other system
libraries such as Arrow/Parquet, Blosc (required for EOPFZARR format), 
muparser and ExprTk (for GDAL expression Pixel functions), NETCDF and perhaps 
others. 

There is also an option to install the latest binary version from 
ubuntugis-unstable using apt. 

## Usage
First, clone the repository and then run the makefile commands as needed (simple `make` should do the trick):

```bash
make # cleans and builds GDAL from source combination of make cleanup and make install

make cleanup # removes all build files and existing GDAL installation

make install # installs GDAL from source

make apt-install # installs GDAL from ubuntugis-unstable PPA

```


> [!NOTE]
> There is also a utils directory where I have (and intend to add more) scripts to help resolve random GDAL related issues.