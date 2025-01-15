#!/bin/bash
#=========================================================================#
# Script: Install siesta-4.1-b4 Parallel  and related Tools  with netcdf4 #
#=========================================================================#      
# Authors: Narender Kumar and Dr Mohan L Verma                            #  
#         Computational Nanomaterials Research Lab                        #
#         Department Of Applied Physics,                                  # 
#         Shri Shankaracharya Technical Campus                            # 
#         Bhilai (Chhattisgarh)  INDIA  web :  www.drmlv.in               #
#                   July 15,         year 2020        		     #
#======================================================================== #
# Acknoledged to   Dr. Arun Kumar,                                        #
#                  Department of Physics, Swami Vivekanand Govt.          #
#                  College Ghumarwin, Distt Bilaspur (H.P) INDIA          #
#-------------------------------------------------------------------------#
#This script helps you to install siesta in parallel mode including       #
# required libraries (netcdf-4.7.3, netcdf-fortran-4.5.2, zlib-1.2.11,    #
# hdf5-1.8.16, openmpi-1.8.7, BLAS-3.8.0, lapack-3.8.0 and scalapack-2.10)#
#-------------------------------------------------------------------------#
# Before running script, make sure your system is connected with stable   #
# internet connection.                                                    #
# HOW TO RUN THIS SCRIPT						     #
# (1) open terminal and type "chmod +x mlv_parallel_siesta_install.sh"    #
# (it will convert your script in binary form)                            #
# (2) now type "sh mlv_parallel_siesta_install.sh"                        #
# (3) and your password ****                                              #        
#======================================================================== #
# After successfull Compilation binary files siesta.exe and related       #
# tools will be generated in linked to /usr/local/bin for further use     #
# For verification of instalattion use the run command as :               #
#  mpirun siesta.exe    
# You can give feedback in:                                               #
#      bansalnarender25@gmail.com, and/or drmohanlv@gmail.com             #
#=========================================================================#
start=`date +%s`

sudo apt-get install m4
sudo apt-get install gcc
sudo apt-get install g++
sudo apt-get install gfortran

mkdir $HOME/parallel_SIESTA
cd $HOME/parallel_SIESTA
sudo wget  https://launchpad.net/siesta/4.1/4.1-b4/+download/siesta-4.1-b4.tar.gz
tar -xzvf siesta-4.1-b4.tar.gz

cd siesta-4.1-b4/Obj/
sh ../Src/obj_setup.sh
cp gfortran.make arch.make
sudo apt-get install m4
wget https://sourceforge.net/projects/libpng/files/zlib/1.2.11/zlib-1.2.11.tar.gz
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.16/src/hdf5-1.8.16.tar.bz2
wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.5.2.tar.gz
wget https://github.com/Unidata/netcdf-c/archive/v4.7.3.tar.gz
mv v4.7.3.tar.gz netcdf-4.7.3.tar.gz

z_v=1.2.11
h_v=1.8.16
nc_v=4.7.3
nf_v=4.5.2

ID=$(pwd)/build

mkdir -p $ID

file_exists zlib-${z_v}.tar.gz
file_exists hdf5-${h_v}.tar.bz2
file_exists netcdf-${nc_v}.tar.gz
file_exists netcdf-fortran-${nf_v}.tar.gz
unset file_exists

#################
# Install z-lib #
#################
[ -d $ID/zlib/${z_v}/lib64 ] && zlib_lib=lib64 || zlib_lib=lib
if [ ! -d $ID/zlib/${z_v}/$zlib_lib ]; then
    tar xfz zlib-${z_v}.tar.gz
    cd zlib-${z_v}
    ./configure --prefix $ID/zlib/${z_v}
    retval $? "zlib config"
    make
    retval $? "zlib make"
    make test 2>&1 | tee zlib.test
    retval $? "zlib make test"
    make install
    retval $? "zlib make install"
    mv zlib.test $ID/zlib/${z_v}/
    cd ../
    rm -rf zlib-${z_v}
    echo "Completed installing zlib"
    [ -d $ID/zlib/${z_v}/lib64 ] && zlib_lib=lib64 || zlib_lib=lib
else
    echo "zlib directory already found."
fi

################
# Install hdf5 #
################
[ -d $ID/hdf5/${h_v}/lib64 ] && hdf5_lib=lib64 || hdf5_lib=lib
if [ ! -d $ID/hdf5/${h_v}/$hdf5_lib ]; then
    tar xfj hdf5-${h_v}.tar.bz2
    cd hdf5-${h_v}
    mkdir build ; cd build
    ../configure --prefix=$ID/hdf5/${h_v} \
	--enable-shared --enable-static \
	--enable-fortran --with-zlib=$ID/zlib/${z_v} \
	LDFLAGS="-L$ID/zlib/${z_v}/$zlib_lib -Wl,-rpath=$ID/zlib/${z_v}/$zlib_lib"
    retval $? "hdf5 configure"
    make
    retval $? "hdf5 make"
    make check-s 2>&1 | tee hdf5.test
    retval $? "hdf5 make check-s"
    make install
    retval $? "hdf5 make install"
    mv hdf5.test $ID/hdf5/${h_v}/
    cd ../../
    rm -rf hdf5-${h_v}
    echo "Completed installing hdf5"
    [ -d $ID/hdf5/${h_v}/lib64 ] && hdf5_lib=lib64 || hdf5_lib=lib
else
    echo "hdf5 directory already found."
fi

####################
# Install NetCDF-C #
####################
[ -d $ID/netcdf/${nc_v}/lib64 ] && cdf_lib=lib64 || cdf_lib=lib
if [ ! -d $ID/netcdf/${nc_v}/$cdf_lib ]; then
    tar xfz netcdf-${nc_v}.tar.gz
    cd netcdf-c-${nc_v}
    mkdir build ; cd build
    ../configure --prefix=$ID/netcdf/${nc_v} \
	--enable-shared --enable-static \
	--enable-netcdf-4 --disable-dap \
	CPPFLAGS="-I$ID/hdf5/${h_v}/include -I$ID/zlib/${z_v}/include" \
	LDFLAGS="-L$ID/hdf5/${h_v}/$hdf5_lib -Wl,-rpath=$ID/hdf5/${h_v}/$hdf5_lib \
-L$ID/zlib/${z_v}/$zlib_lib -Wl,-rpath=$ID/zlib/${z_v}/$zlib_lib"
    retval $? "netcdf configure"
    make
    retval $? "netcdf make"
    make install
    retval $? "netcdf make install"
    cd ../../
    rm -rf netcdf-c-${nc_v}
    echo "Completed installing C NetCDF library"
    [ -d $ID/netcdf/${nc_v}/lib64 ] && cdf_lib=lib64 || cdf_lib=lib
else
    echo "netcdf directory already found."
fi

##########################
# Install NetCDF-Fortran #
##########################
if [ ! -e $ID/netcdf/${nc_v}/$cdf_lib/libnetcdff.a ]; then
    tar xfz netcdf-fortran-${nf_v}.tar.gz
    cd netcdf-fortran-${nf_v}
    mkdir build ; cd build
    ../configure CPPFLAGS="-DgFortran -I$ID/zlib/${z_v}/include \
	-I$ID/hdf5/${h_v}/include -I$ID/netcdf/${nc_v}/include" \
	LIBS="-L$ID/zlib/${z_v}/$zlib_lib -Wl,-rpath=$ID/zlib/${z_v}/$zlib_lib \
	-L$ID/hdf5/${h_v}/$hdf5_lib -Wl,-rpath=$ID/hdf5/${h_v}/$hdf5_lib \
	-L$ID/netcdf/${nc_v}/$cdf_lib -Wl,-rpath=$ID/netcdf/${nc_v}/$cdf_lib \
	-lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz" \
	--prefix=$ID/netcdf/${nc_v} --enable-static --enable-shared
    retval $? "netcdf-fortran configure"
    make
    retval $? "netcdf-fortran make"
    make check 2>&1 | tee check.serial
    retval $? "netcdf-fortran make check"
    make install
    retval $? "netcdf-fortran make install"
    mv check.serial $ID/netcdf/${nc_v}/
    cd ../../
    rm -rf netcdf-fortran-${nf_v}
    echo "Completed installing Fortran NetCDF library"
else
    echo "netcdf-fortran library already found."
fi

##########################
# Completed installation #
##########################

echo "Please add this to the BOTTOM of your arch.make file"

{
echo ""
echo "INCFLAGS += -I$ID/netcdf/${nc_v}/include"
echo "LDFLAGS += -L$ID/zlib/${z_v}/$zlib_lib -Wl,-rpath=$ID/zlib/${z_v}/$zlib_lib"
echo "LDFLAGS += -L$ID/hdf5/${h_v}/$hdf5_lib -Wl,-rpath=$ID/hdf5/${h_v}/$hdf5_lib"
echo "LDFLAGS += -L$ID/netcdf/${nc_v}/$cdf_lib -Wl,-rpath=$ID/netcdf/${nc_v}/$cdf_lib"
echo "LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz"
echo "COMP_LIBS += libncdf.a libfdict.a"
echo "FPPFLAGS += -DCDF -DNCDF -DNCDF_4"
echo "" 
} >> arch.make
############################# openmpi ################################################################################
cd MPI/

wget https://download.open-mpi.org/release/open-mpi/v1.8/openmpi-1.8.7.tar.gz
tar -xzvf openmpi-1.8.7.tar.gz

cd openmpi-1.8.7/
 ./configure --prefix=$HOME/parallel_SIESTA/siesta-4.1-b4/Obj/MPI/
make -j
make install
cd ../bin
sudo cp mpicc /usr/local/bin
sudo cp mpirun /usr/local/bin
sudo cp mpif90 /usr/local/bin
cd ../

############################# BLAS####################################################################################
mkdir BLAS
cd BLAS/
wget www.netlib.org/blas/blas-3.8.0.tgz
tar zxf blas-3.8.0.tgz
cd BLAS-3.8.0/
make -j
mv blas_LINUX.a libblas.a
sudo cp libblas.a /usr/local/lib/
cd ../../

############################# LAPACK ##################################################################################
mkdir LAPACK
cd LAPACK/
wget www.netlib.org/lapack/lapack-3.8.0.tar.gz
tar xvf lapack-3.8.0.tar.gz
cd lapack-3.8.0/
cp make.inc.example make.inc
make lib
sudo cp liblapack.a /usr/local/lib/
cd ../../

######################## scalapack #####################################################################################
mkdir SCALAPACK
cd SCALAPACK/
wget www.netlib.org/scalapack/scalapack-2.1.0.tgz
tar zxf scalapack-2.1.0.tgz
cd scalapack-2.1.0
cp SLmake.inc.example SLmake.inc
make lib
sudo cp libscalapack.a /usr/local/lib/
cd ../../../
########################################################################################################################
sed -i "s|SIESTA_ARCH = unknown|SIESTA_ARCH = amd64 (x86_64)|g" arch.make
sed -i "s|CC = gcc|CC = mpicc|g" arch.make
sed -i "s|FC = gfortran|FC = mpif90|g" arch.make
sed -i "s|FC_SERIAL = gfortran|#FC_SERIAL = gfortran|g" arch.make
sed -i "s|COMP_LIBS = libsiestaLAPACK.a libsiestaBLAS.a|COMP_LIBS= /usr/local/lib/liblapack.a /usr/local/lib/libblas.a /usr/local/lib/libscalapack.a|g" arch.make
sed -i "s|FPPFLAGS = |#FPPFLAGS =|g" arch.make
sed -i '40iFPPFLAGS= -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT' arch.make
sed -i "s|LIBS =|#LIBS =|g" arch.make
sed -i '42iLIBS = $(SCALAPACK_LIBS) $(LAPACK_LIBS) $(MPI_LIBS) $(COMP_LIBS)' arch.make
sed -i '44iBLAS_LIBS=-lblas' arch.make
sed -i '45iLAPACK_LIBS=-llapack' arch.make
sed -i '46iBLACS_LIBS=-lblas' arch.make
sed -i '47iSCALAPACK_LIBS="/usr/local/lib/libscalapack.a"' arch.make
sed -i "s|FFLAGS_DEBUG = -g -O1|FFLAGS_DEBUG = -g -O2|g" arch.make
sed -i '51iMPI_INTERFACE=libmpi_f90.a' arch.make
sed -i '52iMPI_INCLUDE=.' arch.make
##========================Final Compilation of SIESTA ==================================================================
sh ../Src/obj_setup.sh
sudo make
sudo mv siesta siesta.exe
sudo cp siesta.exe /usr/local/bin
###========================compilation of post processing Tools =========================================================
cd ../Util/Bands
sudo make 
sudo cp gnubands /usr/local/bin/        #For bands plotting using gnuplot or xmgrace
cd ../Eig2DOS
sudo make
sudo cp Eig2DOS /usr/local/bin/         # for DOS plotting using xmgrace
cd ../Contrib/APostnikov/
sudo make
sudo cp rho2xsf /usr/local/bin/         # for charge density using xcrysden 
sudo cp xv2xsf /usr/local/bin/          # for structural analysis using xcrysden and find symmentry points for bands plot
sudo cp fmpdos /usr/local/bin/          # for PDOS plotting 
###======================================================================================================================
#Test the compilation by using command :
# mpirun siesta.exe
# To run the program the command used is : mpirin -np <number of cores> *.fdf | tee *.out 
#
#====== Enjoy computing with siesta============All the Best==============================================================
#
############################### PLEASE DO NOT SHARE WITHOUT PERMISSION###################################################
#
#========================================================================================================================= 

end=`date +%s`



