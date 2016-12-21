#!/bin/sh

#utilisaiton: ./synth_no_component.sh nomdufichiervhdl

vasy -p -I vhdl -V -o -a $1.vhdl $1
#boom -V $1 $1_o
boog $1 $1

