set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Clock

set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 \
    -name clk \
    [get_ports clk]

# Reset

set_property PACKAGE_PIN C12 [get_ports res_n]
set_property IOSTANDARD LVCMOS33 [get_ports res_n]

# Pass Led

set_property PACKAGE_PIN H17    [get_ports led_pass]
set_property IOSTANDARD LVCMOS33 [get_ports led_pass]
