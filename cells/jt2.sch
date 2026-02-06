v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {pscan_type=rules 
body=\{RULE GO(GET(IN))
    INC(J1),
    SET(OUT),
    INC(J2);
\}} 190 20 0 0 0.2 0.2 {}
N -70 -50 -70 -0 {lab=#net1}
N -70 -50 -50 -50 {lab=#net1}
N 10 -50 50 -50 {lab=#net2}
N 110 -50 110 -0 {lab=#net3}
N -70 60 110 60 {lab=0}
N 30 -70 30 -50 {lab=#net2}
N 30 60 30 110 {lab=0}
N -100 -130 -100 -100 {lab=0}
N -100 -130 30 -130 {lab=0}
N -140 -50 -70 -50 {lab=#net1}
N 110 -50 190 -50 {lab=#net3}
N 250 -50 280 -50 {lab=OUT}
N -230 -50 -200 -50 {lab=IN}
C {ind.sym} 80 -50 1 0 {name=L1 model=L? value=0.75}
C {ind.sym} -20 -50 1 0 {name=L2 model=L? value=0.75}
C {isrc.sym} 30 -100 0 0 {name=I0 model=I? value=2.8}
C {gnd.sym} 30 110 0 0 {name=l3 lab=0}
C {gnd.sym} -100 -100 0 0 {name=l4 lab=0}
C {ind.sym} -170 -50 1 0 {name=L5 model=L? value=0.75}
C {ind.sym} 220 -50 1 0 {name=L6 model=L? value=0.75}
C {iopin.sym} 280 -50 0 0 {name=p1 lab=OUT}
C {iopin.sym} -230 -50 2 0 {name=p2 lab=IN}
C {jj.sym} -70 30 0 0 {name=J1 model=J value=2}
C {jj.sym} 110 30 0 0 {name=J2 model=J value=2}
