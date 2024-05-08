if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]
then
	echo "%{F#585B70}󰂲"
else
	bt_info=$(bt-device -l)
	if [ $(echo info | bluetoothctl | grep 'Device' | wc -c) -eq 0 ]
	then 
	echo "%{F#A6E3A1}"
	fi
	echo "%{F#89B4FA}󰂱"
fi
