#!/bin/sh
#spc1.sh A B
#A : SPC1 TEST PHASE
#B : SPC1 IOPS
cmd=$1
iops=$2

date=$(date '+%Y-%m-%d_%H:%M:%S')
date_time=$(date '+%H:%M:%S')
log_home="/root/Q_sh/fio_log"

echo "ready?"
read 

mkdir -p $log_home"/"$date
log_dir=$log_home"/"$date
sys_log=$log_dir"/inventory_start.out"
sys_log_end=$log_dir"/inventory_end.out"
mdadm_log=$log_dir"/mdadm.log"
stat_log_dir=$log_dir"/stat"
parm_log=$log_dir"/parm.log"
mkdir -p $stat_log_dir

cp /root/Q_sh/fio_script/fio.sh $log_dir"/fio-backup.sh"

echo "1. Get host information."

cat /etc/os-release >> $sys_log
echo -e "==============================================\n" >> $sys_log
uname -r >> $sys_log
echo -e "==============================================\n" >> $sys_log
nvme list >> $sys_log
echo -e "==============================================\n" >> $sys_log
lsblk -b >> $sys_log
echo -e "==============================================\n" >> $sys_log
fdisk -l >> $sys_log
echo -e "==============================================\n" >> $sys_log
#cat /proc/mdstat >> $sys_log
#echo -e "==============================================\n" >> $sys_log
pvs --units G >> $sys_log
echo -e "==============================================\n" >> $sys_log
vgs --units G >> $sys_log
echo -e "==============================================\n" >> $sys_log
lvs --units G -v --segment >> $sys_log
echo -e "==============================================\n" >> $sys_log

echo "2. Get NVMe information.(smartctl)"

echo ====================host================= >> $sys_log
dn=$(ls /dev/nvme? | wc -l)
for ((i=0;i<$dn;i++));
do
	echo +++++++++++++++++++++/dev/nvme$i++++++++++++++++++ >> $sys_log
	smartctl -a /dev/nvme$i >> $sys_log
done

echo "3. Get Storage-RAID information."

echo ====================host================= >> $mdadm_log
dn=$(ls /dev/md? | wc -l)
for ((i=1;i<=$dn;i++));
do	
	echo +++++++++++++++++++++/dev/md$i++++++++++++++++++ >> $mdadm_log
	mdadm -D /dev/md$i >> $mdadm_log
done
echo +++++++++++++++++++++/etc/mdadm.conf++++++++++++++++++ >> $mdadm_log
cat /etc/mdadm.conf >> $mdadm_log


echo "4. Get host disk parameter."

devs=$(ls /dev/nvme?n? | awk -F '/' '{print $3}')
echo =====================host===================== >> $parm_log

for dev in $devs;
do
	echo +++++++++++++++/dev/$dev+++++++++++++++ >> $parm_log
	#devices configuration setup
	echo -n 'nr_requests : ' >> $parm_log
	cat /sys/block/$dev/queue/nr_requests >> $parm_log
	echo -n 'scheduler : ' >> $parm_log
	cat /sys/block/$dev/queue/scheduler >> $parm_log
	echo -n 'max_sectors_kb : ' >> $parm_log
	cat /sys/block/$dev/queue/max_sectors_kb >> $parm_log
	echo -n 'add_random : ' >> $parm_log
	cat /sys/block/$dev/queue/add_random >> $parm_log
	echo -n 'nomerges : ' >> $parm_log
	cat /sys/block/$dev/queue/nomerges >> $parm_log
done
#OS configuration setup
echo '+++++++++++++++system parameter+++++++++++++++' >> $parm_log
echo -n 'aio-max-nr : '	>> $parm_log
echo '----------------------------------------------' >> $parm_log
cat /proc/sys/fs/aio-max-nr >> $parm_log
echo 'ulimit -a' >> $parm_log
ulimit -a >> $parm_log
echo '----------------------------------------------' >> $parm_log
echo 'ulimit -aH' >> $parm_log
ulimit -aH >> $parm_log


echo "5. Get storage RAID-Volume parameter."

devs=$(ls /dev/md? | awk -F '/' '{print $3}')

echo =====================host===================== >> $parm_log

for dev in $devs;
do
	echo +++++++++++++++/dev/$dev+++++++++++++++ >> $parm_log
	#devices configuration setup
	echo -n 'nr_requests : ' >> $parm_log
	cat /sys/block/$dev/queue/nr_requests >> $parm_log
	echo -n 'scheduler : ' >> $parm_log
	cat /sys/block/$dev/queue/scheduler >> $parm_log
	echo -n 'max_sectors_kb : ' >> $parm_log
	cat /sys/block/$dev/queue/max_sectors_kb >> $parm_log
	echo -n 'add_random : ' >> $parm_log
	cat /sys/block/$dev/queue/add_random >> $parm_log
	echo -n 'nomerges : ' >> $parm_log
	cat /sys/block/$dev/queue/nomerges >> $parm_log
done


echo "6. Start monitoring system."
		
#host
/root/Q_sh/fio_script/kill.sh vmstat
/root/Q_sh/fio_script/kill.sh iostat
rm -rf /tmp/*stat.log
vmstat -t 10 > /tmp/vmstat.log &
iostat -mtx 10 > /tmp/iostat.log &

echo "7. Start FIO Test."
sleep 1
echo -n "3.."
sleep 1
echo -n "2.."
sleep 1
echo -n "1.."
sleep 1
echo "Start!!"
sleep 2

## running fio
cd /root/fio
./fio mixed.ini

echo "8. Get system monitoring logs."
		
#host
/root/Q_sh/fio_script/kill.sh vmstat
/root/Q_sh/fio_script/kill.sh iostat
cp /tmp/vmstat.log $stat_log_dir"/vmstat.log"
cp /tmp/iostat.log $stat_log_dir"/iostat.log"



nvme list >> $sys_log_end
echo -e "==============================================\n" >> $sys_log_end
lsblk -b >> $sys_log_end
echo -e "==============================================\n" >> $sys_log_end
fdisk -l >> $sys_log_end
echo -e "==============================================\n" >> $sys_log_end
#cat /proc/mdstat >> $sys_log_end
#echo -e "==============================================\n" >> $sys_log_end
pvs --units G >> $sys_log_end
echo -e "==============================================\n" >> $sys_log_end
vgs --units G >> $sys_log_end
echo -e "==============================================\n" >> $sys_log_end
lvs --units G -v --segment >> $sys_log_end
echo -e "==============================================\n" >> $sys_log_end

echo ====================host================= >> $sys_log_end
dn=$(ls /dev/nvme? | wc -l)

for ((i=0;i<=$dn;i++));
do
	echo +++++++++++++++++++++/dev/nvme$i++++++++++++++++++ >> $sys_log_end
        smartctl -a /dev/nvme$i >> $sys_log_end
done


echo =====================host=====================
rm -rf /tmp/*stat.log


echo "9. log detach"
cp /root/Q_sh/fio_script/graph.sh $stat_log_dir
./graph.sh


echo "10. Backup & Update git"

cd /root/Q_sh/
git add --all
git commit -m "hoon"
git push
