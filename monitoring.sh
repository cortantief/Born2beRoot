#!/bin/bash

FILEO=$(mktemp)

print_message () {
	echo "    #$1:" $2 >> $FILEO
}

SUDO_SEQ_FILE="/var/log/sudo/seq"

print_message "Architecture" "$(uname -a)"

# Source : https://developpaper.com/how-to-view-the-physical-cpu-logical-cpu-and-cpu-number-of-linux-servers/

print_message "CPU physical" "$(cat /proc/cpuinfo | grep 'physical id' | sort | uniq | wc -l)"

print_message "vCPU" "$(cat /proc/cpuinfo | grep 'processor' | wc -l)"

FREE_IN_MB=$(free --mega -w| grep Mem | grep -o '[[:digit:]]\+' | xargs)
USED_RAM=$(echo $FREE_IN_MB | cut -d ' ' -f 2)
FREE_RAM=$(echo $FREE_IN_MB | cut -d ' ' -f 3)
PERCENT_RAM=$(awk -v FREE_RAM="$FREE_RAM" -v USED_RAM="$USED_RAM" 'BEGIN{ printf "%.2f\n", (USED_RAM / FREE_RAM) * 100 }')
print_message "Memory Usage (MB)" "$USED_RAM/$FREE_RAM ($PERCENT_RAM%)"

DISK_IN_GB=$(df -BM | grep "/$" | xargs)

PERC_DISK=$(echo $DISK_IN_GB | cut -d ' ' -f 5)
USED_DISK=$(echo $DISK_IN_GB | cut -d ' ' -f 3 | grep "[[:digit:]]\+" -o)
AVA_DISK=$(echo $DISK_IN_GB | cut -d ' ' -f 2 | grep "[[:digit:]]\+" -o)
print_message "Disk Usage (MB)" "$USED_DISK/$AVA_DISK ($PERC_DISK)"
print_message "CPU load" "$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.2f", usage}')%"


BOOT_OP=$(who -b | xargs)

print_message "Last boot" "$(echo $BOOT_OP | cut -d ' ' -f 3) $(echo $BOOT_OP | cut -d ' ' -f 4)"


print_message "LVM use" "$(if grep -F '/dev/mapper/' /etc/fstab &>/dev/null ; then echo 'yes';else echo 'no'; fi)"

print_message "Connexions TCP" "$(ss -ant | grep ESTAB| wc -l)"
print_message "User log" "$(users | wc -w)"

IP_ADDR=$(hostname -I |cut -d ' ' -f 1)
print_message "Network" "$IP_ADDR ($(ip addr show | grep $IP_ADDR -B 1 | head -n 1 | xargs | cut -d ' ' -f 2))"


# https://stackoverflow.com/questions/4614775/converting-hex-to-decimal-in-awk-or-sed/32437561

print_message "Sudo" "$(cat $SUDO_SEQ_FILE | awk -Wposix '{printf("%d\n","0x" $1)}') cmd"

wall < $FILEO
rm -rf $FILEO
