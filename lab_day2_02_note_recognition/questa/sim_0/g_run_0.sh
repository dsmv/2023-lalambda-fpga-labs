#vsim tb_opt -do "wave.tcl"
#qhsim -sv_lib ../build/libkeeper_session tb_opt -classdebug -do "wave.tcl" 
qhsim  tb_opt -classdebug -do "wave.tcl" 