# # # Main file - the one we want to use for ConjProdAlphaProf_Top # # #

#I had seen online to apply clock constraints to the positive terminal of differential clocks
#So, hopefully this works
# 1/200MHz = 5nS
# 1/400MHz = 2.5nS
#create_clock -period 2.500 [get_ports clk_P]

#Use the clock from the standard User Clock 200MHz Differential Clock Oscillator
# 200MHz Clock
create_clock -period 5.000 [get_ports clk_P]

set_property PACKAGE_PIN E19 [get_ports clk_P]
set_property IOSTANDARD LVDS [get_ports clk_P]

set_property PACKAGE_PIN E18 [get_ports clk_N]
set_property IOSTANDARD LVDS [get_ports clk_N]

#And just assign reset to a button to help PAR out
# set_property PACKAGE_PIN AR40 [get_ports reset]
# set_property IOSTANDARD LVCMOS18 [get_ports reset]
