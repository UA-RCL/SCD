@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim DualPortRAM_tb_behav -key {Behavioral:sim_1:Functional:DualPortRAM_tb} -tclbatch DualPortRAM_tb.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
