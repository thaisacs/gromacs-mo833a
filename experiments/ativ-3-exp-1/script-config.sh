#!/bin/bash
#Author : Thais Camacho

BIN='../../../build/bin/gmx'
SLVN='../config/6LVN.pdb'
IONS='../config/ions.mdp'

mkdir -p experiment
cd experiment

echo '15' | $BIN pdb2gmx -f $SLVN -o 6LVN_processed.gro -water spce
$BIN editconf -f 6LVN_processed.gro -o 6LVN_newbox.gro -c -d 1.0 -bt cubic
$BIN solvate -cp 6LVN_newbox.gro -cs spc216.gro -o 6LVN_solv.gro -p topol.top
$BIN grompp -f $IONS -c 6LVN_solv.gro -p topol.top -o ions.tpr
echo '13' | $BIN genion -s ions.tpr -o 6LVN_solv_ions.gro -p topol.top -pname NA -nname CL -neutral
$BIN grompp -f $IONS -c 6LVN_solv_ions.gro -p topol.top -o em.tpr
