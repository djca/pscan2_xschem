proc set_pscan2_sim_dir {} {
    global pscan2_sim_dir
    set pscan2_sim_dir [tk_chooseDirectory -initialdir $pscan2_sim_dir]
    file mkdir $pscan2_sim_dir
}
