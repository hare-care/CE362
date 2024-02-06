
create_clock -name clk -period 1.0 -waveform { 0 0.5 } [get_ports clk]


# ------------------------- Input constraints ----------------------------------

#set_input_delay -clock clk -max 0.2 [get_ports {din start rstb wr_ctrl_test_crtl}]
#set_input_delay -clock clk -min -0.2 [get_ports {din start rstb wr_ctrl_test_crtl}]

# ------------------------- Output constraints ---------------------------------

#set_output_delay -clock clk -max 0.2 [get_ports {addr_out*}]
#set_output_delay -clock clk -min -0.2 [get_ports {addr_out*}]


set_max_delay 1.0 -from [all_inputs] -to [all_outputs]

# Assume 50fF load capacitances everywhere:
set_load 0.050 [all_outputs]
# Set 10fF maximum capacitance on all inputs
set_max_capacitance 0.010 [all_inputs]

# set clock uncertainty of the system clock (skew and jitter)
set_clock_uncertainty -setup 0.03 [get_clocks clk*]
set_clock_uncertainty -hold 0.06 [get_clocks clk*]


# set maximum transition at output ports
set_max_transition 0.07 [current_design]

# set_attr use_scan_seqs_for_non_dft false
