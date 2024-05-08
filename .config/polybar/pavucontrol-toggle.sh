#!/bin/sh

if [ $(pgrep ^pavucontrol$ | wc -c) -eq 0 ]
then
	exec pavucontrol -t 1&
else
	exec pkill -KILL pavucontrol
fi
