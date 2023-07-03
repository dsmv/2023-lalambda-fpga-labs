cp -R step1/src/* ../src
cp -R step1/tb/*  ../tb
cp -R step1/program/p0_program/main.S     ../program/p0_program
cp -R step1/program/p0_program/Makefile   ../program/p0_program
cp -R step1/program/p0_program/p_build.sh ../program/p0_program

cp -R step1/icarus/* ../icarus
cp -R step1/questa/* ../questa

# rm -fr ../tb/*
# rm -fr ../program/p0_program/*
# rm -fr ../icarus/sim_0/*
# rm -fr ../questa/sim_0/*