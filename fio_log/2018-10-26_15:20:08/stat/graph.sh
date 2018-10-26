#!/bin/sh

dir="graph"

mkdir $dir
txts=$(ls *iostat.log)
#txts=$(ls *.log)

for txt in $txts
do
	output_txt=$(echo $txt | awk -F '_' '{print $1}')
	cat $txt | grep "avg-cpu" -A 1 | grep "    " >> "$dir/"$output_txt"_cpu.log"
	
	echo -n "$dir/"$output_txt"_cpu.log : "
	cat "$dir/"$output_txt"_cpu.log" | wc -l

	devs=$(cat $txt | awk -F '     ' '{print $1}' | grep nvme | sort -u)
	for dev in $devs
	do
		cat $txt | grep $dev >> "$dir/"$output_txt"_$dev.log"

		echo -n "$dir/"$output_txt"_$dev.log : "
		cat "$dir/"$output_txt"_$dev.log" | wc -l
	done
done
