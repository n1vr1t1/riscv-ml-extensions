set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 110.000 -name clk -waveform {0.000 55.000} -add [get_ports clk]

set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports rst]
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports led]