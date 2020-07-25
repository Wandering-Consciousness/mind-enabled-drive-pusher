#
#!/bin/bash       


# Check if XCode command line tools are installed, if not install them via prompt 
XCodeTools(){
# Check if X-Code is installed, if not install it 
if xcode-select --install 2>&1 | grep installed; then
  echo "Xcode Command Line Tools are installed";
else
  echo "Xcode Command Line Tools are missing!";
  echo "Installing Xcode Command Line Tools..";
  read -p "Finished Installing Xcode? Press enter key to continue installation.. "
fi
}

# Check if Homebrew is installed, install if we don't have it, update if we do
homebrew() {
	if [[ $(command -v brew) == "" ]]; then 
		echo "Installing Homebrew.. "
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	else
		echo "Updating Homebrew.. "
		brew update
	fi
}

# Install Cmake
install_cmake(){
    echo "Installing cmake.. "
   brew install cmake
}
# Install Library USB needed to communicate to the QRNG 
installLibUSB(){
    cd libusb-1.0.9
    ./configure
    make
    make install
    ln -s /usr/local/include/libusb-1.0/libusb.h /usr/local/include/libusb.h
    cd ..
}

# Install the FTDI chip firmware this is needed to understand whats coming back from USB
installFTDI(){
cd libftdi1-1.3
cmake $PWD
make
make install
ln -s /usr/local/include/libftdi1/ftdi.h /usr/local/include/ftdi.h
cd ..
}


#simply setup the QNG Library
installQNG(){

# Lets use LLVM because apple clang is crap
brew update && brew install libomp && brew install llvm 

# setup LLVM variables in order to not have problems with OpenMP
export CC="/usr/local/opt/llvm/bin/clang -fopenmp"
export CXX="/usr/local/opt/llvm/bin/clang++ -fopenmp"
export CFLAGS="-O3 -mtune=native"
export CXXFLAGS="-O3 -mtune=native"
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"
export CPATH="/usr/local/include:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/"

cd libqwqng-1.4
cmake $PWD
make
make install

}

# Main funciton to install the driver on OS X for liqwqng by comscire 
InstallDriver(){
printf "Step 1/4 This will install build-essentials, Xcode Command Line Tools, Homebrew Package Manager, CMAKE, and libconfuse.\n"

# Install Xcode
XCodeTools

# Install Homebrew
homebrew

# install cmake
install_cmake

# install LibUSB
printf "Step 2/4 Installing libUSB.\n"
installLibUSB

# Install LIBFTDI1
printf "Step 3/4 Installing FTDI Chip Driver.\n"
installFTDI

# Install the QRNG
printf "Step 4/4 Installing and setting up comscire RNG\n"
installQNG

}


#run it 
InstallDriver