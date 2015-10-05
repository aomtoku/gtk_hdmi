# Vivado Launch Script in batch mode

source app_gui.tcl

generate_target all [get_ips]

reset_run synth_1 
launch_run [get_runs synth_1]

wait_on_run synth_1

reset_run impl_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1
open_run impl_1
set_property SEVERITY {Warning} [get_drc_checks NSTD-1] 
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -bitgen_options {-g UnconstrainedPins:Allow} -file top.bit -force
#launch_run -to_step write_bitstream [get_runs impl_1]

#wait_on_run impl_1
