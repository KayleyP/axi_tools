vcom -work work -2002 -explicit -stats=none C:/Workspace/VHDL/aes3_tx.vhd
vcom -work work -2002 -explicit -stats=none C:/Workspace/VHDL/aes3_tb.vhd
vcom -work work -2002 -explicit -stats=none C:/Workspace/VHDL/aes3rx-master/rtl/vhdl/example_aes3_rx.vhd

vsim work.aes3_tb
add wave -position insertpoint  \
sim:/aes3_tb/comp_aes3_tx/s_clk \
sim:/aes3_tb/comp_aes3_tx/aes_data \
sim:/aes3_tb/comp_aes3_tx/b_clk \
sim:/aes3_tb/comp_aes3_tx/lr_clk \
sim:/aes3_tb/comp_aes3_tx/lr_fe \
sim:/aes3_tb/comp_aes3_tx/lr_re \
sim:/aes3_tb/comp_aes3_tx/aes_sr \
sim:/aes3_tb/comp_aes3_tx/aes_data_i \
sim:/aes3_tb/comp_aes3_tx/sm_state \
sim:/aes3_tb/comp_aes3_tx/s_count \
sim:/aes3_tb/comp_aes3_tx/aes_preamble

add wave -position end  sim:/aes3_tb/comp_aes3rx/x_detected
add wave -position end  sim:/aes3_tb/comp_aes3rx/y_detected
add wave -position end  sim:/aes3_tb/comp_aes3rx/z_detected
add wave -position end  sim:/aes3_tb/comp_aes3rx/sdata
add wave -position end  sim:/aes3_tb/comp_aes3rx/sclk
add wave -position end  sim:/aes3_tb/comp_aes3rx/lrck
add wave -position end  sim:/aes3_tb/comp_aes3rx/active
add wave -position end  sim:/aes3_tb/comp_aes3rx/bsync
add wave -position end  sim:/aes3_tb/comp_aes3rx/decoder_shift
add wave -position end  sim:/aes3_tb/comp_aes3rx/clk
add wave -position end  sim:/aes3_tb/comp_aes3_tx/s_clk

run -all