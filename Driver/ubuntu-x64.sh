#
#!/bin/bash          

#install all required packages
installPreq(){
	echo ' '
	echo 'http://packages.ubuntu.com/precise/build-essential'
	echo 'https://cmake.org/'
	echo 'http://libusb.info/'
	echo 'https://github.com/martinh/libconfuse'
	echo ' '

	printf 'Step 1/4 This will install build-essentials, CMAKE, LIBUSB, and libconfuse.\n'
	printf '\t apt-get update\n'
	sudo apt-get -qq update -y


	printf '\t apt-get install build-essential\n'
	sudo apt-get -qq install build-essential -y
	printf '\t apt-get install cmake\n'
	sudo apt-get -qq install cmake -y
	printf '\t apt-get install libusb-1.0-0 libusb-1.0-0-dev\n'
	sudo apt-get -qq install libusb-1.0-0 libusb-1.0-0-dev -y
	printf '\t apt-get install libconfuse-dev\n'
	sudo apt-get -qq install libconfuse-dev -y
	
	printf '\t Fixing libUSB symlinks\n'

	if [ -e /usr/local/lib/libusb-1.0.a ]; then
		printf '\t [/usr/local/lib/libusb-1.0.a] exists\n'
	else
		if [ -e /usr/lib/x86_64-linux-gnu/libusb-1.0.a ]; then
			sudo ln -s /usr/lib/x86_64-linux-gnu/libusb-1.0.a /usr/local/lib/libusb-1.0.a
			printf '\t [/usr/lib/x86_64-linux-gnu/libusb-1.0.a] has been linked to [/usr/local/lib/libusb-1.0.a]\n'
		else
			printf '\t [/usr/lib/x86_64-linux-gnu/libusb-1.0.a] DOES NOT EXIST\n'
		fi
	fi

	if [ -e /usr/local/lib/libusb-1.0.so ]; then
		printf '\t [/usr/local/lib/libusb-1.0.so] exists\n'
	else
		if [ -e /usr/lib/x86_64-linux-gnu/libusb-1.0.so ]; then
			sudo ln -s /usr/lib/x86_64-linux-gnu/libusb-1.0.so /usr/local/lib/libusb-1.0.so
			printf '\t [/usr/lib/x86_64-linux-gnu/libusb-1.0.so] has been linked to [/usr/local/lib/libusb-1.0.so]\n'
		else
			printf '\t [/usr/lib/x86_64-linux-gnu/libusb-1.0.so] DOES NOT EXIST\n'
		fi
	fi


	echo ' '
	installBOOST
}

#install boost for unit testing
installBOOST(){
	printf 'Step 2/4 This will install Boost and Doxygen (optional).\n'
	printf '\t apt-get install libboost-all-dev\n'
	sudo apt-get -qq install libboost-all-dev -y
	printf '\t apt-get install doxygen\n'
	sudo apt-get -qq install doxygen -y
	echo ' '
	installFTDI
}

#we need to build and manually install libftdi on each system
installFTDI(){
	printf 'Step 3/4 This will install libftdi (not the official D2XX drivers).\n'
	echo ' '
	echo 'https://www.intra2net.com/en/developer/libftdi/index.php'
	echo ' '

	printf '\t apt-get install libftdi-dev\n'
	sudo apt-get -qq install libftdi-dev -y

	printf '\t Fixing libFTDI symlinks\n'
	
	if [ -e /usr/local/include/ftdi.h ]; then
		printf '\t [/usr/local/include/ftdi.h] exists\n'
	else
		if [ -e /usr/include/ftdi.h ]; then
			sudo ln -s /usr/include/ftdi.h /usr/local/include/ftdi.h
			printf '\t [/usr/include/ftdi.h] has been linked to [/usr/local/include/ftdi.h]\n'
		else
			printf '\t [/usr/include/ftdi.h] DOES NOT EXIST\n'
		fi
	fi

	if [ -e /usr/local/lib/libftdi1.a ]; then
		printf '\t [/usr/local/lib/libftdi1.a] exists\n'
	else
		if [ -e /usr/lib/x86_64-linux-gnu/libftdi.a ]; then
			sudo ln -s /usr/lib/x86_64-linux-gnu/libftdi.a /usr/local/lib/libftdi1.a
			printf '\t [/usr/lib/x86_64-linux-gnu/libftdi.a] has been linked to [/usr/local/lib/libftdi1.a]\n'
		else
			printf '\t [/usr/lib/x86_64-linux-gnu/libftdi.a] DOES NOT EXIST\n'
		fi
	fi
	if [ -e /usr/local/lib/libftdi1.so ]; then
		printf '\t [/usr/local/lib/libftdi1.so] exists\n'
	else
		if [ -e /usr/lib/x86_64-linux-gnu/libftdi.so ]; then
			sudo ln -s /usr/lib/x86_64-linux-gnu/libftdi.so /usr/local/lib/libftdi1.so
			printf '\t [/usr/lib/x86_64-linux-gnu/libftdi.so] has been linked to [/usr/local/lib/libftdi1.so]\n'
		else
			printf '\t [/usr/lib/x86_64-linux-gnu/libftdi.so] DOES NOT EXIST\n'
		fi
	fi

	echo ' '
	installQNG
}

#simply setup the QNG Library
installQNG(){

	printf 'Step 4/4 This will build and install the QNG Library.\n'

	if [ -e /usr/local/lib64/libqwqng.a ]; then
		printf '\t QWQNG Library Already Installed, this will reinstall the library\n'
	fi

	#build library
	cd libqwqng-1.4
	mkdir build
	cd build
	sudo cmake ../
	sudo make
	sudo make install

	# Install UDEV rules
	printf '\t Modifying UDEV rules to allow users to access ComScire QNG device.'
	sudo cp ~/libqwqng-1.4/packages/45-libqwqng.rules /etc/udev/rules.d/

	# Reload UDEV rules 
	printf '\t Restarting UDEV rules (unplug QNG device if connected)'
	udevadm control --reload-rules

	printf '\t libQWQNG installed into /usr/local/lib64/..\n'

	echo ' '
	finished
}

#we done here let's exit
finished(){
	echo 'QWC QNG Setup Completed!'
	exit
}

#intro
startup(){
	echo 'Preparing your system, internet, and root required...'
	installPreq
}

#launches other arch script
launchOther(){
	sudo ./test-86.sh
	exit
}

#checks OS version
checkOS(){
	printf 'Checking OS...'
	osRelease=$(gcc --version)

	case "$osRelease" in
		*'Ubuntu'*) printf 'Found Ubuntu\n\n'; checkARCH;;
		*) printf '\n\tThis script only supports Ubuntu\n\n'; exit;;
	esac
}

#checks installed OS arch type
checkARCH(){
	printf 'Checking Architecture...'
	arch=$(uname -m)

	case "$arch" in
		*'x86_64'*) printf 'Found x64/x86_64\n\n'; startup;;
		*) printf '\n\tThis script only supports Ubuntu x64/x86_64, launching x86 version...\n\n'; launchOther; exit;;
	esac
}

#run the function
checkOS