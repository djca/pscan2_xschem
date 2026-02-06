v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {pscan_type=parameter body=\{TSEQ=400.0, TP=100.0\}} 110 -50 0 0 0.2 0.2 {}
T {pscan_type=internal body=\{p1=0.85+tvec("d1")\}} 110 -30 0 0 0.2 0.2 {}
T {pscan_type=rules 
body=\{rule m1go(inc(p1))
        set(m1.in);
\}} 440 -160 0 0 0.2 0.2 {}
T {pscan_type=design_info body=\{is_root=True\}} 0 -170 0 0 0.2 0.2 {}
N 0 -20 0 0 {lab=0}
N 0 -120 0 -80 {lab=#net1}
N 0 -120 40 -120 {lab=#net1}
N 110 -120 140 -120 {lab=#net2}
N 210 -120 240 -120 {lab=#net3}
N 310 -120 360 -120 {lab=#net4}
C {jt2.sym} 80 -120 0 0 {name=m1}
C {psrc.sym} 0 -50 0 0 {name=P1}
C {gnd.sym} 0 0 0 0 {name=l1 lab=0}
C {jt2.sym} 180 -120 0 0 {name=m2}
C {jt2.sym} 280 -120 0 0 {name=m3}
C {stdload.sym} 400 -120 0 0 {name=m4}
