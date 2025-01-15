#!/bin/bash
#=========================================================================#
# Script: Install SIESTA Parallel, serial mode and all required libraries #
#-------------------------------------------------------------------------#
# Author: Narender Kumar,                                                 #  
#         Research Assistant, Computational Nanomaterials                 #
#         Research Lab, Department Of Applied Physics, SSTC-SSGI          # 
#         Junwani, Bhilai (Chhattisgarh)  INDIA                           #
#   August 8,         year 2020                                           #
#-------------------------------------------------------------------------#
# Inspired By: Dr. Mohan L Verma                                          #
#                  Computational Nanomaterials Research Lab,              #
#                  Department Of Applied Physics, SSTC-SSGI               # 
#                  Junwani, Bhilai (Chhattisgarh)  INDIA                  #
#              Dr. Arun Kumar,                                            #
#                  Department of Physics, Swami Vivekanand Govt.          #
#                  College Ghumarwin, Distt Bilaspur (H.P) INDIA          #
#-------------------------------------------------------------------------#
#     Author Would like to acknowledge Nick R. Papior for Writting        #
#    Installation Script for zlib, hdf5, netcdf-c and netcdf-fortran      #
#-------------------------------------------------------------------------#
# to run this script use following commands :                             #
# chmod +x install_siesta.sh						     #
# ./install_siesta.sh 							     #
# You can give feedback in:                                               #
#                           bansalnarender25@gmail.com                    #
#=========================================================================#
start=`date +%s`

sudo apt-get install m4
sudo apt-get install gcc
sudo apt-get install g++
sudo apt-get install gfortran



if [[ ! -d "$HOME/SIESTA" ]] ;
then
mkdir $HOME/SIESTA
cd $HOME/SIESTA/
else
cd $HOME/SIESTA/
fi
read -p "Which version of siesta you want ?
1) siesta-v4.1.5
2) siesta-4.1-b3 
Type your Answer With b5 or b3 $foo ? [b5/b3] " answer
###########################################################################
if [[ $answer = b5 ]] ;
then
echo "Downloading version b5... "
if [[ ! -d "$HOME/SIESTA/siesta-v4.1.5" ]] ; then 
wget  https://gitlab.com/siesta-project/siesta/-/archive/v4.1.5/siesta-v4.1.5.tar.gz
tar -xzvf siesta-v4.1.5.tar.gz
version=siesta-v4.1.5
else
version=siesta-v4.1.5
fi
else
echo "Downloading version b3... "
if [[ ! -d "$HOME/SIESTA/siesta-4.1-b3" ]] ; then 
wget https://launchpad.net/siesta/4.1/4.1-b3/+download/siesta-4.1-b3.tar.gz
tar -xzvf siesta-4.1-b3.tar.gz
version=siesta-4.1-b3
else
version=siesta-4.1-b3
fi
fi
################################################################################
cd $version/
cd Obj/

read -p "Do you want install siesta in parallel mode?
$foo? [y/n] " answer
if [[ $answer = y ]] ;
then
sh ../Src/obj_setup.sh
cp gfortran.make arch.make
##################################################################################
if [[ -f "$HOME/SIESTA/$version/Obj/hdf5-1.8.16.tar.bz2" ]]
then
echo "hdf5-1.8.16.tar.bz2 File Exist"
else
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.16/src/hdf5-1.8.16.tar.bz2
fi
###################################################################################
if [[ -f "$HOME/SIESTA/$version/Obj/netcdf-c-4.8.1.tar.gz" ]]
then
echo "netcdf-c-4.8.1.tar.gz File Exist"
else
wget https://downloads.unidata.ucar.edu/netcdf-c/4.8.1/netcdf-c-4.8.1.tar.gz

fi
###################################################################################
if [[ -f "$HOME/SIESTA/$version/Obj/netcdf-fortran-4.5.4.tar.gz" ]]
then
echo "netcdf-fortran-4.5.4.tar.gz File Exist"
else
wget https://downloads.unidata.ucar.edu/netcdf-fortran/4.5.4/netcdf-fortran-4.5.4.tar.gz
fi
###################################################################################
if [[ -f "$HOME/SIESTA/$version/Obj/zlib-1.2.11.tar.gz" ]]
then
echo "zlib-1.2.11.tar.gz File Exist"
else
wget https://sourceforge.net/projects/libpng/files/zlib/1.2.11/zlib-1.2.11.tar.gz
fi
##################################################################################
z_v=1.2.11
h_v=1.8.16
nc_v=4.8.1
nf_v=4.5.4

if [ -z $PREFIX ]; then
    ID=$(pwd)/build
else
    ID=$PREFIX
fi


echo "Installing libraries in folder: $ID"
mkdir -p $ID

# First we check that the user have downloaded the files
function file_exists {
    if [ ! -e $(pwd)/$1 ]; then
	echo "I could not find file $1..."
	echo "Please download the file and place it in this folder:"
	echo " $(pwd)"
	exit 1
    fi
}
# Check for function $?
function retval {
    local ret=$1
    local info="$2"
    shift 2
    if [ $ret -ne 0 ]; then
	echo "Error: $ret"
	echo "$info"
	exit 1
    fi
}

file_exists zlib-${z_v}.tar.gz
file_exists hdf5-${h_v}.tar.bz2
file_exists netcdf-c-${nc_v}.tar.gz
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
    tar xfz netcdf-c-${nc_v}.tar.gz
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
    make check 2>&1 | tee check.fortran.serial
    retval $? "netcdf-fortran make check"
    make install
    retval $? "netcdf-fortran make install"
    mv check.fortran.serial $ID/netcdf/${nc_v}/
    cd ../../
    rm -rf netcdf-fortran-${nf_v}
    echo "Completed installing Fortran NetCDF library"
else
    echo "netcdf-fortran library already found."
fi

##########################
# Completed installation #
##########################
echo ""
echo "##########################"
echo "# Completed installation #"
echo "#   of NetCDF package    #"
echo "#  and its dependencies  #"
echo "##########################"
echo ""
echo ""

echo "Please add the following to the BOTTOM of your arch.make file"
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

###########################################################
cd MPI/
if [[ ! -f "$HOME/SIESTA/$version/Obj/MPI/openmpi-1.8.7.tar.gz" ]]
then
wget https://download.open-mpi.org/release/open-mpi/v1.8/openmpi-1.8.7.tar.gz
tar -xzvf openmpi-1.8.7.tar.gz
cd openmpi-1.8.7/
 ./configure --prefix=$HOME/SIESTA/$version/Obj/MPI/
make -j
make install
cd ../bin/
sudo cp mpicc /usr/local/bin
sudo cp mpirun /usr/local/bin
sudo cp mpif90 /usr/local/bin
cd ../
else
echo "***Checking openmpi***"
if [[ ! -f "$HOME/SIESTA/$version/Obj/MPI/bin/mpicc" && "$HOME/SIESTA/$version/Obj/MPI/bin/mpif90" && "$HOME/SIESTA/$version/Obj/MPI/bin/mpirun" ]]
then
rm -R openmpi-1.8.7
tar -xzvf openmpi-1.8.7.tar.gz
cd openmpi-1.8.7/
 ./configure --prefix=$HOME/SIESTA/$version/Obj/MPI/
make -j
make install
cd ../bin/
sudo cp mpicc /usr/local/bin
sudo cp mpirun /usr/local/bin
sudo cp mpif90 /usr/local/bin
cd ../
else
#cd ../
echo "***openmpi installed successfully***"
fi
fi
############################# BLAS ###################################
######################################################################
if [[ ! -d "$HOME/SIESTA/$version/Obj/MPI/BLAS" ]]
then
mkdir BLAS
cd BLAS/
wget www.netlib.org/blas/blas-3.8.0.tgz
tar zxf blas-3.8.0.tgz
cd BLAS-3.8.0/
make -j
mv blas_LINUX.a libblas.a
sudo cp libblas.a /usr/local/lib/
cd ../../
else
echo "Checking BLAS..."
if [[ ! -f "$HOME/SIESTA/$version/Obj/MPI/BLAS/BLAS-3.8.0/libblas.a" ]]
then
cd BLAS/
rm -R BLAS-3.8.0
tar zxf blas-3.8.0.tgz
cd BLAS-3.8.0/
make -j
mv blas_LINUX.a libblas.a
sudo cp libblas.a /usr/local/lib/
cd ../../
else
#cd ../
echo "***BLAS installed successfully***"
fi
fi
############################# LAPACK ##############################
###################################################################
if [[ ! -d "$HOME/SIESTA/$version/Obj/MPI/LAPACK" ]] 
then
mkdir LAPACK
cd LAPACK/
wget www.netlib.org/lapack/lapack-3.8.0.tar.gz
tar xvf lapack-3.8.0.tar.gz
cd lapack-3.8.0/
cp make.inc.example make.inc
make lib
sudo cp liblapack.a /usr/local/lib/
cd ../../
else
echo "Checking LAPACK..."
if [[ ! -f "$HOME/SIESTA/$version/Obj/MPI/LAPACK/lapack-3.8.0/liblapack.a" ]]
then
cd LAPACK/
rm -R lapack-3.8.0
tar xvf lapack-3.8.0.tar.gz
cd lapack-3.8.0/
cp make.inc.example make.inc
make lib
sudo cp liblapack.a /usr/local/lib/
cd ../../
else
#cd ../../
echo "***LAPACK installed successfully***"
fi
fi
######################## scalapack ################################
###################################################################
if [[ ! -d "$HOME/SIESTA/$version/Obj/MPI/SCALAPACK" ]] 
then
mkdir SCALAPACK
cd SCALAPACK/
wget www.netlib.org/scalapack/scalapack-2.1.0.tgz
tar zxf scalapack-2.1.0.tgz
cd scalapack-2.1.0/
cp SLmake.inc.example SLmake.inc
make lib
sudo cp libscalapack.a /usr/local/lib/
cd ../../../
else
echo "Checking SCALAPACK..."
if [[ ! -f "$HOME/SIESTA/$version/Obj/MPI/SCALAPACK/scalapack-2.1.0/libscalapack.a" ]]
then
cd SCALAPACK/
rm -R scalapack-2.1.0
tar zxf scalapack-2.1.0.tgz
cd scalapack-2.1.0/
cp SLmake.inc.example SLmake.inc
make lib
sudo cp libscalapack.a /usr/local/lib/
cd ../../../
else
cd ../
echo "***SCALAPACK installed successfully***"
fi
fi
#########################################################################
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

if [[ ! -f "$HOME/SIESTA/$version/Obj/siesta.exe" ]] 
then
sh ../Src/obj_setup.sh
make
mv siesta siesta.exe
sudo cp siesta.exe /usr/local/bin
cd ../
else
echo "***Parallel mode of Siesta Installed successfully***"
cd ../
fi
###################################################################
else
sh ../Src/obj_setup.sh
if [[ ! -f "$HOME/SIESTA/$version/Obj/siesta.exe" ]] 
then
cp gfortran.make arch.make
make
sudo cp siesta /usr/local/bin
cd ../
else
cd ../
mkdir Obj_serial
cd Obj_serial/
sh ../Src/obj_setup.sh
cp ../Obj/gfortran.make arch.make
make
sudo cp siesta /usr/local/bin
cd ../
fi
fi
################################################################
read -p "Do you wish to install Transiesta $foo? [y/n] " answer
if [[ $answer = y ]] ;
then
echo "Checking Libraries For Transiesta"
if [[ ! -d "$HOME/SIESTA/$version/Obj_transiesta" ]] 
then
mkdir Obj_transiesta
cd Obj_transiesta/
cp ../Obj/arch.make .
sh ../Src/obj_setup.sh
make transiesta
sudo cp transiesta /usr/local/bin
cd ../
else
echo "Checking for Transiesta"
if [[ ! -f "$HOME/SIESTA/$version/Obj_transiesta/transiesta" ]]
then
cd Obj_transiesta/
cp ../Obj/arch.make .
sh ../Src/obj_setup.sh
make transiesta
sudo cp  transiesta /usr/local/bin
cd ../
else
echo "***Transiesta installed successfully***"
fi
fi
fi
######################################################################
read -p "Do you wish to install utilities TBtransiesta, Eig2DOS, gnubands etc..... $foo? [y/n] " answer
if [[ $answer = y ]] ;
then
cd Util/TS/TBtrans
 make
        sudo cp  tbtrans  /usr/local/bin 
cd ../../Bands/
 make
         sudo cp  gnubands  /usr/local/bin 
         cd ../Contrib/APostnikov/
 make
         sudo cp  rho2xsf  /usr/local/bin
         sudo cp  xv2xsf  /usr/local/bin
         sudo cp  fmpdos  /usr/local/bin 
         cd ../../COOP/
 make
       sudo cp  mprop  /usr/local/bin  
       cd ../Eig2DOS/
 make
       sudo cp  Eig2DOS  /usr/local/bin
       fi
 
echo "
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
you can give feedback in:-
                           bansalnarender25@gmail.com"


end=`date +%s`
echo Execution time was `expr $end - $start` seconds.




