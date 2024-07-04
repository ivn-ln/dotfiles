#!/bin/sh

if [ $(pgrep com.github.cal | wc -c) -eq 0 ]
then
	exec & flatpak run com.github.calo001.luna
else
	exec pkill -KILL com.github.cal
fi
