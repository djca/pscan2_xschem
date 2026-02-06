# ---- your command ----
proc gen_full_hdl {} {
    global pscan2_sim_dir
    global PSCAN2_XSCHEM_DIR

set result [tk_messageBox \
    -title "Write full HDL Confirmation" \
    -message "This will write all HDL files in the hierarchy and overwrite *.HDL files in $pscan2_sim_dir. Proceed?" \
    -type yesno \
    -icon question]

if {$result eq "yes"} {
    set sch_name [xschem get current_name]
    exec python3 [file join $PSCAN2_XSCHEM_DIR scripts gen_hdl.py] $sch_name $pscan2_sim_dir
    return
} else {
    return
}

}


# ---- your command ----
proc gen_single_hdl {} {
    global pscan2_sim_dir
    global PSCAN2_XSCHEM_DIR

set sch_name [xschem get current_name]
# set schematic_dir [file dirname [xschem get current_name]]



set result [tk_messageBox \
    -title "Write current HDL Confirmation" \
    -message "This will write HDL for $sch_name in $pscan2_sim_dir. Proceed?" \
    -type yesno \
    -icon question]

if {$result eq "yes"} {

    exec python3 [file join $PSCAN2_XSCHEM_DIR scripts gen_hdl.py] $sch_name $pscan2_sim_dir single
    set name [file rootname [file tail $sch_name]]
    set hdl_file "$name.hdl"
    textwindow $pscan2_sim_dir/$hdl_file 

	return
} else {
    return
}

}
