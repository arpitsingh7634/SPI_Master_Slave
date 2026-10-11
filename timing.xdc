
## Basys 3 (Artix-7 XC7A35T-1CPG236C) constraints


set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


create_generated_clock -name spi_clk_gen -source [get_ports clk] -divide_by 8 [get_pins u_master/spi_clk_reg/Q]


set_property PACKAGE_PIN R2 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]


set_property PACKAGE_PIN V17 [get_ports {parallel_data[0]}]
set_property PACKAGE_PIN V16 [get_ports {parallel_data[1]}]
set_property PACKAGE_PIN W16 [get_ports {parallel_data[2]}]
set_property PACKAGE_PIN W17 [get_ports {parallel_data[3]}]
set_property PACKAGE_PIN W15 [get_ports {parallel_data[4]}]
set_property PACKAGE_PIN V15 [get_ports {parallel_data[5]}]
set_property PACKAGE_PIN W14 [get_ports {parallel_data[6]}]
set_property PACKAGE_PIN W13 [get_ports {parallel_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {parallel_data[*]}]


set_property PACKAGE_PIN T18 [get_ports data_valid]
set_property IOSTANDARD LVCMOS33 [get_ports data_valid]


set_property PACKAGE_PIN U16 [get_ports {received_data[0]}]
set_property PACKAGE_PIN E19 [get_ports {received_data[1]}]
set_property PACKAGE_PIN U19 [get_ports {received_data[2]}]
set_property PACKAGE_PIN V19 [get_ports {received_data[3]}]
set_property PACKAGE_PIN W18 [get_ports {received_data[4]}]
set_property PACKAGE_PIN U15 [get_ports {received_data[5]}]
set_property PACKAGE_PIN U14 [get_ports {received_data[6]}]
set_property PACKAGE_PIN V14 [get_ports {received_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {received_data[*]}]


set_property PACKAGE_PIN L1 [get_ports received_valid]
set_property IOSTANDARD LVCMOS33 [get_ports received_valid]


set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]