# Repository and output directories
set script_dir [file dirname [file normalize [info script]]]
set repo_dir [file normalize [file join $script_dir ".." ".."]]

set build_dir [file join $repo_dir fpga build]
set project_name "rv32i_nexys"
set project_dir [file join $build_dir $project_name]
set project_file [file join $project_dir "${project_name}.xpr"]

# Do not overwrite an existing generated project
if {[file exists $project_dir]} {
    error "Output directory already exists: $project_dir. Use a fresh output directory."
}

# Design sources, with packages listed first
set rtl_paths {
    rtl/src/core/pkg_riskv_types.vhd
    rtl/src/core/pkg_riskv_pipeline.vhd
    rtl/src/core/program_counter.vhd
    rtl/src/core/instruction_memory.vhd
    rtl/src/core/register_file.vhd
    rtl/src/core/immediate_generator.vhd
    rtl/src/core/alu_ctrl.vhd
    rtl/src/core/alu.vhd
    rtl/src/core/branch_jump_unit.vhd
    rtl/src/core/load_unit.vhd
    rtl/src/core/store_unit.vhd
    rtl/src/core/control_unit.vhd
    rtl/src/core/forwarding_unit.vhd
    rtl/src/core/hazard_detection_unit.vhd
    rtl/src/core/data_memory.vhd
    rtl/src/core/mmio_memory.vhd
    rtl/src/top/rv32i_core.vhd
    fpga/rtl/src/fpga_top.vhd
}

set rtl_files {}
foreach relative_path $rtl_paths {
    lappend rtl_files [file join $repo_dir $relative_path]
}

set tb_file [file join $repo_dir fpga rtl tb tb_fpga_top.vhd]
set xdc_file [file join $repo_dir fpga constraints fpga_top.xdc]

set imem_file [file join $repo_dir software build instr.mem]
set dmem_file [file join $repo_dir software build data.mem]

set clk_ip_file [file join $repo_dir fpga ip clk_wiz_0 clk_wiz_0.xci]
set ila_ip_file [file join $repo_dir fpga ip ila_0 ila_0.xci]

# Check inputs before creating the project
set required_files [concat $rtl_files [list \
    $tb_file \
    $xdc_file \
    $imem_file \
    $dmem_file \
    $clk_ip_file \
    $ila_ip_file \
]]

foreach input_file $required_files {
    if {![file isfile $input_file]} {
        error "Required input file not found: $input_file"
    }
}

# Create project
file mkdir $build_dir

create_project $project_name $project_dir \
    -part xc7a100tcsg324-1

set_property target_language VHDL [current_project]
set_property simulator_language Mixed [current_project]
set_property target_simulator XSim [current_project]
set_property default_lib xil_defaultlib [current_project]

# Add RTL sources
add_files -norecurse -fileset sources_1 $rtl_files

foreach rtl_file $rtl_files {
    set_property FILE_TYPE {VHDL 2008} \
        [get_files [list $rtl_file]]
}

# Add memory initialization files
add_files -norecurse -fileset sources_1 \
    [list $imem_file $dmem_file]

set_property FILE_TYPE {Memory File} \
    [get_files [list $imem_file $dmem_file]]

# Add constraints
add_files -norecurse -fileset constrs_1 [list $xdc_file]

# Add simulation testbench
add_files -norecurse -fileset sim_1 [list $tb_file]
set_property FILE_TYPE {VHDL 2008} \
    [get_files [list $tb_file]]

# Import IP into the generated project
import_ip  [list $clk_ip_file $ila_ip_file]

foreach ip_name {clk_wiz_0 ila_0} {
    set ip_obj [get_ips $ip_name]

    if {[get_property IS_LOCKED $ip_obj]} {
        error "IP is locked: $ip_name. Check Vivado version and IP status."
    }

    set ip_xci [get_files -all "*/${ip_name}.xci"]
    set_property GENERATE_SYNTH_CHECKPOINT false $ip_xci
}

generate_target all [get_ips {clk_wiz_0 ila_0}]

# Select hardware and simulation tops
set_property top fpga_top [get_filesets sources_1]
set_property top tb_fpga_top [get_filesets sim_1]
set_property top_auto_set false [get_filesets sim_1]

# Configure memory paths for synthesis and RTL simulation
set memory_generics [list \
    [format {IMEM_INIT_FILE="%s"} $imem_file] \
    [format {DMEM_INIT_FILE="%s"} $dmem_file] \
]

set_property generic $memory_generics [get_filesets sources_1]
set_property generic $memory_generics [get_filesets sim_1]

# Preserve the original hierarchy setting
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY \
    none [get_runs synth_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

report_ip_status -file [file join $project_dir ip_status.rpt]

puts "INFO: Repository: $repo_dir"
puts "INFO: Instruction memory: $imem_file"
puts "INFO: Data memory: $dmem_file"
puts "INFO: Project created: $project_file"
puts "INFO: Synthesis and implementation have NOT been launched."

close_project
