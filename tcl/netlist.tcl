proc pscan2_netlist {} {

    global netlist_dir
    global pscan2_sim_dir

    set netlist_dir $pscan2_sim_dir

    # xschem save
    xschem netlist

    set sch_path [xschem get current_name]

    # basename only (no directory, no .sch)
    set name [file rootname [file tail $sch_path]]

    set spice_file [file join $netlist_dir "$name.spice"]
    set cir_file   [file join $netlist_dir "$name.cir"]

    if {![file exists $spice_file]} {
        puts "Error: $spice_file not found"
        return
    }

    set in  [open $spice_file r]
    set out [open $cir_file w]

    while {[gets $in line] >= 0} {
        if {[string trim $line] ne ""} {
            puts $out $line
        }
    }

    close $in
    close $out

    puts "Created: $cir_file"
}
