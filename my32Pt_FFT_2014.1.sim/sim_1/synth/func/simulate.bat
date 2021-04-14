@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim FloP_Complex_Mult_tb_func_synth -key {Post-Synthesis:sim_1:Functional:FloP_Complex_Mult_tb} -tclbatch FloP_Complex_Mult_tb.tcl -view C:/Users/jmack2545.ENGR-RCL08G/Documents/FPGA/my32Pt_FFT/FFT_32_Pt_tb_behav2.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
