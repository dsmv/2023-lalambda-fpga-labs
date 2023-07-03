#set WAVEWIN [view .main_pane.wave.interior.cs.body.pw.wf]
#set WAVEWIN [view .main_pane.wave.interior.cs.body.pw.wf]
set WAVEWIN [view .main_pane.wave]
#set WAVEWIN [view -new wave]
# add wave -position end  sim:/tb_12_top/uut_cn12/*

add wave -radix hex /tb/*
add wave -radix hex /tb/uut/*