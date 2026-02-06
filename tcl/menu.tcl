# ---- create menu AFTER GUI exists ----
after idle {

    # menubar exists now
    set m .menubar

    menu $m.pscan2 -tearoff 0

    $m add cascade -label "PSCAN2" -menu $m.pscan2

    $m.pscan2 add command \
        -label "Set PSCAN2 sim directory" \
        -command set_pscan2_sim_dir  

    $m.pscan2 add command \
        -label "Write HDL (full hierarchy)" \
        -command gen_full_hdl

    $m.pscan2 add command \
        -label "Write HDL (current schematic)" \
        -command gen_single_hdl

    $m.pscan2 add command \
        -label "Write PSCAN2 Netlist (.CIR)" \
        -command pscan2_netlist
}
