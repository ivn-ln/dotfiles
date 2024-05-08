#!/bin/sh

if [ $(pgrep ^kalendar$ | wc -c) -eq 0 ]
then
	exec kalendar&
else
	exec pkill -KILL kalendar
fi
