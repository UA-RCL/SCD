@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xelab  -wto 12bb78b6f5024cda8a7ec0ab9fa616fd -m64 --debug typical --relax --mt 16 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot DualPortRAM_tb_behav xil_defaultlib.DualPortRAM_tb xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
