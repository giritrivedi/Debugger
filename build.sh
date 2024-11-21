! #/bin/sh

DEBUGGER_DIR=`pwd`
RUNTIME_DIR=`pwd`/runtime
DIAGNOSTICS_DIR=`pwd`/diagnostics
NETCOREDBG_DIR=`pwd`/netcoredbg
CORECLR_DIR=$RUNTIME_DIR/src/coreclr
DBGSHIM_DIR=$DIAGNOSTICS_DIR/artifacts/bin/linux.s390x.Debug/

#echo $RUNTIME_DIR
#echo $DIAGNOSTICS_DIR
#echo $NETCOREDBG_DIR
#echo $CORECLR_DIR
#echo $DEBUGGER_DIR

build_diagnostics()
{
  echo "Building Diagnostics.."
  mkdir rc2
  cd rc2
  #get rc2 sdk
  wget https://github.com/IBM/dotnet-s390x/releases/download/v9.0.100-rc.2.24474.11/dotnet-sdk-9.0.100-rc.2.24474.11-linux-s390x.tar.gz
  tar -xvf dotnet-sdk-9.0.100-rc.2.24474.11-linux-s390x.tar.gz
  rm dotnet-sdk-9.0.100-rc.2.24474.11-linux-s390x.tar.gz
  export PATH=`pwd`:$PATH
 
  #copy SDK to .dotnet
  cd $DIAGNOSTICS_DIR 
  rm -rf .dotnet
  cp -r ../rc2/ .dotnet/

  #modify global.json file
  sed -i '5,8d' global.json 
  sed -i 's/9.0.100/9.0.100-rc.2.24474.11/' global.json 

  export LLDB_H=`pwd`/src/SOS/lldbplugin/swift-4.0/

  ./build.sh /p:UseAppHost=false

  #restore global.json
  git restore global.json
  cd ..
  echo "Building Diagnostics.. DONE"
}

build_runtime()
{
  echo "Building Runtime.."

  mkdir preview3
  cd preview3
  wget https://github.com/IBM/dotnet-s390x/releases/download/v9.0.100-preview.3.24204.13/dotnet-sdk-9.0.100-preview.3.24204.13-linux-s390x.tar.gz
  tar -xvf dotnet-sdk-9.0.100-preview.3.24204.13-linux-s390x.tar.gz
  rm dotnet-sdk-9.0.100-preview.3.24204.13-linux-s390x.tar.gz
  echo PATH=`pwd`:$PATH

  cd $RUNTIME_DIR 
  rm -rf .dotnet
  cp -r ../preview3/ .dotnet/
  ./build.sh mono+mono.runtime+mono.mscordbi -keepnativesymbols true
  cd ..

  echo "Building Runtime.. DONE"
}
build_netcoredbg()
{
  echo "Building Netcordbg.."
  cd $NETCOREDBG_DIR 
  export PATH=$DEBUGGER_DIR/preview3/:$PATH
  rm -rf build
  mkdir build
  cd build
  CC=clang CXX=clang++ cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_FLAGS="-g3 -O0" -DCMAKE_CXX_FLAGS="-g3 -O0" -DCORECLR_DIR=$CORECLR_DIR -DDOTNET_DIR=$DEBUGGER_DIR/preview3/ -DDBGSHIM_DIR=$DBGSHIM_DIR
  make
  make install
  echo "Building Netcordbg.. DONE"
}

build_diagnostics
build_runtime
build_netcoredbg
