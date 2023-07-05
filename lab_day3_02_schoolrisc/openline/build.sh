#export openline_dir="/home/verilog/OpenLane"
#echo $openline_dir
#make -f $openline_dir/Makefile OPENLINE_DIR=$openline_dir TEST_DESIGN=schoolriscv test

make  TEST_DESIGN=schoolriscv test