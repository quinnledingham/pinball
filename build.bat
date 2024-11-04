@echo off

REM create build directory
pushd %CD%
set folder= %CD%

IF NOT EXIST build mkdir build
cd build

odin build %folder% -debug

cd ..
