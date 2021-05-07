#!/bin/bash
a=7.2
b=8

if [ `echo "$a < $b"|bc` -eq 1 ] ; then
echo  "$a < $b "
else
echo "$a > $b "
fi
