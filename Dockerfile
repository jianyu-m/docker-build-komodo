FROM ubuntu:16.04
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb http://download.mono-project.com/repo/debian wheezy main" > /etc/apt/sources.list.d/mono-xamarin.list
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates-mono nuget
RUN cert-sync /etc/ssl/certs/ca-certificates.crt
RUN nuget update -self
RUN apt-get update

Run apt-get install g++ gcc cmake build-essential unzip git -y

Run git clone https://github.com/microsoft/Komodo /komodo

WORKDIR /komodo

# install dependencies
Run git submodule init && git submodule update

Run apt-get install scons fsharp nuget mono-devel wget -y

WORKDIR /komodo/tools/vale/

Run ln -s /komodo/tools/dafny/z3.exe /usr/bin/z3

Run nuget restore ./tools/Vale/src/packages.config -PackagesDirectory tools/FsLexYacc

Run scons --DAFNYPATH=$PWD/../dafny bin/vale.exe

# install z3
WORKDIR /komodo
COPY img/z3-4.6.0-x64-ubuntu-16.04.zip ./

Run unzip z3-4.6.0-x64-ubuntu-16.04.zip
Run cp -r z3-4.6.0-x64-ubuntu-16.04 tools/dafny/z3
Run cp -r z3-4.6.0-x64-ubuntu-16.04 tools/vale/bin/z3

# install cross-compilation compiler
COPY img/gcc-linaro-4.9-2016.02-x86_64_arm-eabi.tar.xz ./
RUN tar xf gcc-linaro-4.9-2016.02-x86_64_arm-eabi.tar.xz

# apply the patch to ignore verification
COPY ./noverify.patch /komodo/
Run git apply noverify.patch

COPY ./kernel7.img ./
# Run export PATH=$PATH:/komodo/gcc-linaro-4.9-2016.02-x86_64_arm-eabi/bin/
Run PATH=$PATH:/komodo/gcc-linaro-4.9-2016.02-x86_64_arm-eabi/bin/ make

# build the newest linux arm distribution
# Run git clone https://github.com/raspberrypi/tools /tools
# Run export PATH=$PATH:/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin
# Run git clone --depth=1 https://github.com/raspberrypi/linux /linux
# Run apt-get install git bison flex libssl-dev
# Run KERNEL=kernel7 make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig

