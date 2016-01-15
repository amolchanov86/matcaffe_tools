#!/bin/bash
matlab -nosplash -nodesktop -logfile ${2}.log -r $1
#EXAMPLE: matlab_cmd.sh "functionmat($var1,$var2)"
