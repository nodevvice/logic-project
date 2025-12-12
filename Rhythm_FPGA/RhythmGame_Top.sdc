#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 13.1.0 Build 162 10/23/2013 SJ Web Edition
#
#************************************************************

# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints

create_clock -name "CLK" -period 20.000ns [get_ports {i_Clk}] -waveform {0.000 10.000}


# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

set_input_delay -clock "CLK" -max 17ns [get_ports {KEY[0] KEY[1] KEY[2] KEY[3] SW[0] SW[1] SW[2] SW[3] SW[4] SW[5] SW[6] SW[7] SW[8] SW[9]}] 


# tco constraints

set_output_delay -clock "CLK" -max 15ns [get_ports {HEX[0] HEX[1] HEX[2] HEX[3] HEX[4] HEX[5] LEDR[0] LEDR[1] LEDR[2] LEDR[3] LEDR[4] LEDR[5] LEDR[6] LEDR[7] LEDR[8] LEDR[9] o_DM_Row[0] o_DM_Row[1] o_DM_Row[2] o_DM_Row[3] o_DM_Row[4] o_DM_Row[5] o_DM_Row[6] o_DM_Row[7] o_DM_Col[0] o_DM_Col[1] o_DM_Col[2] o_DM_Col[3] o_DM_Col[4] o_DM_Col[5] o_DM_Col[6] o_DM_Col[7]}] 


# tpd constraints

