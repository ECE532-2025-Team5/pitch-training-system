## This file is a general .xdc for the Nexys4 DDR Rev. C
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]


##Switches

set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports rst]


## LEDs
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports sd_sw]

##Omnidirectional Microphone

set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports MIC_CLK]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports MIC_DATA]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports MIC_LR_SEL]


##PWM Audio Amplifier

set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports AUD_PWM]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports AUD_SD]
