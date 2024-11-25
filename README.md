Netcoredbg is ported to support s390x architecture. 
"netcordbg" is dependent on "runtime" and "diagnostics" repositories. 
Changes are present in all these repositories. 

A specific version on the runtime repository which has support for "mscordbi" is picked. 
Changes are applied on top of this and runtime is built. 

netcoredbg needs libdbgshim.so, which can be obtained from "diagnostics" repository. 
Diagnostics repo is not build-able as is on s390x architecture. Couple of code changes 
were required to make it build-able on s390x. Once this is built, libdbgshim.so is used 
from this repository while building netcoredbg. 

To build netcoredbg, path to coreclr from runtime and path of libdbgshim.so need to be 
issued to build command of netcoedbg. 

build.sh script takes care of building diagnostics,runtime and netcoredbg to make building of all these repositories easy for the user.
jush run build.sh script, which takes are of everything for you. 

The final executable can be accessed from "netcoredbg/build/src/netcoredbg". 

The debuggee can be debugged using netcoredbg in two ways. 
1. starting the debuggee along with netcoredbg.
2. attaching the dbeuggee to netcoredbg.

This port works as mentioned in #1 above.

Usage:

Copy libcoreclr.so and libmscordbi.so from the runtime directory built above to the the dotnet sdk path. 
cp runtime/artifacts/bin/mono/linux.s390x.Debug/libcoreclr.* <sdk_dir>/shared/Microsoft.NETCore.App/9.0.0-preview.3.24172.9/
cp runtime/artifacts/bin/mono/linux.s390x.Debug/libmscordbi.* <sdk_dir>/shared/Microsoft.NETCore.App/9.0.0-preview.3.24172.9/

To start the debuggee along with the debugger, follow below steps. 
1. export MONO_ENV_OPTIONS='--debugger-agent=transport=dt_socket,address=127.0.0.1:pid_based,server=y,suspend=n,loglevel=5,timeout=100000'
2. cd netcoredbg/build/src
3. ./netcoredbg --interpreter=cli -- dotnet <path to dll>
 
