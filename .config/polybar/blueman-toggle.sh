#!/bin/sh

if [ $(pgrep blueman-manager | wc -c) -eq 0 ]
then
	exec blueman-manager&
else
	exec pkill -KILL blueman-manager
fi
