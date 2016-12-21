#!/bin/sh

#utilisaiton: ./synth_with_component.sh nomdufichier

vasy -p -I vhdl -V -o -a $1.vhdl $1
#boom -V $1_model $1_model_o
boog $1_model $1_model

