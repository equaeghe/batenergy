#!/usr/bin/env bash

FILE=/tmp/batenergy.dat
ADP=(/sys/class/power_supply/A*)
BAT=(/sys/class/power_supply/BAT*)

[[ -e $BAT ]] || exit

state=$1
sleep_type=$2

now=`date +'%s'`

# Read an energy in mWh from /sys/class/power_supply.
# Some firmware only reports charge (in µAh), in which case we convert using voltage.
read_energy() {
	local when=$1
	local -n var=energy_$when
	if [[ -e $BAT/energy_$when ]]; then
		(( var = $(< "$BAT"/energy_$when) / 1000 )) # mWh
	else
		if (( ! voltage_now )); then
			(( voltage_now = $(< "$BAT"/voltage_now) )) # µV
		fi
		(( var = $(< "$BAT"/charge_$when) * voltage_now / 1000000000 )) # mWh
	fi
}

read_energy now
read_energy full

if [[ -f $ADP/online ]]; then
	read online < "$ADP"/online

	if (( online )); then
		echo "Currently on mains."
	else
		echo "Currently on battery."
	fi
fi

case $state in
"pre")
	echo "Saving time and battery energy before sleeping ($sleep_type)."
	echo $now > $FILE
	echo $energy_now >> $FILE
	;;
"post")
	exec 3<>$FILE
	read prev <&3
	read energy_prev <&3
	rm $FILE
	time_diff=$(($now - $prev)) # seconds
	days=$(($time_diff / (3600*24)))
	hours=$(($time_diff % (3600*24) / 3600))
	minutes=$(($time_diff % 3600 / 60))
	echo "Duration of $days days $hours hours $minutes minutes sleeping ($sleep_type)."
	(( energy_diff = energy_now - energy_prev )) # mWh
	(( avg_rate = energy_diff * 3600 / time_diff )) # mW
	energy_diff_pct=$(bc <<< "scale=1;$energy_diff * 100 / $energy_full") # %
	avg_rate_pct=$(bc <<< "scale=2;$avg_rate * 100 / $energy_full") # %/h
	echo "Battery energy change of $energy_diff_pct % ($energy_diff mWh) at an average rate of $avg_rate_pct %/h ($avg_rate mW)."
	;;
esac
