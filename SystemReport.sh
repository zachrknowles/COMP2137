#!/bin/bash
username=$USER
#outputs the date in a  human readable format
date=$(date +%c)
#prints the short hostname
hostname=$(hostname -s)
#allows the use of variables from /etc/os-relase
source /etc/os-release
osname=$PRETTY_NAME
#displays the uptime in a human readable format
timeup=$(uptime | awk '{print $3}' | bc | awk '{printf "%.0f days, %.0f hours, %.0f minutes\n", $1/86400, ($1%86400)/3600, ($1%3600)/60}')
#displays the make and model of the cpu
cpu=$(lscpu | grep 'Model name: '| awk -F ': ' ' {print $2} ')
#displays the maxium cpu speed
cpuspeed=$(sudo dmidecode -t processor | grep -m 1 "Max Speed")
#displays how much RAM the system has in GB
ramsize=$(free -h | awk '/Mem:/{print $2}')
#displays all of the installed disks on the system
installeddisks=$(lsblk -dno KNAME,TYPE,SIZE,MODEL)
#displays all of the installed video cards on the system
installedvideocard=$(lspci -v | grep VGA -A 3)
#finds the domain name for the FQDN
domainname=$(dnsdomainname)
#puts hostname and domain name togther for the FQDN
FQDN=$hostname.$domainname
#gets the ip address for the hostname
hostaddress=$(getent ahosts "$HOSTNAME" | grep STREAM | head -n 1 | cut -d ' ' -f1)
#gets the gateway of the ip address
gateway=$(ip route show default | grep default | awk '{print $3}')
#gets the dns server of the ip address
dns=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
#shows all of the logged in users
loggedinusers=$(who | awk '{print $1}')
#shows all of the free space on the system
diskspace=$(df -hP | grep -v "^Filesystem" | awk '{print $3, $5}')
#displys the total process count
processCount=$(ps aux | wc -l)
#displays the load averages
loadAverages=$(uptime | awk '{print $NF-2, $NF-1, $NF}')
#displays the memory allocation
memoryAllocation=$(free -m | grep Mem: | awk '{print $2, $3, $4}')
#displays the listening Network ports
listeningNetworkPorts=$(ss -ltn | grep LISTEN)
#displays the UFW rules
ufwRules=$(sudo ufw status verbose)


cat <<EOF

System Report generated by $username, $date
 
System Information
------------------
Hostname: $hostname
OS: $osname
Uptime: $timeup
 
Hardware Information
--------------------
cpu:  $cpu
Speed:$cpuspeed
Ram: $ramsize     
Disk(s): $installeddisks
Video: $installedvideocard
 
Network Information
-------------------
FQDN: $FQDN
Host Address:  $hostaddress
Gateway IP:  $gateway
DNS Server:   $dns
 
System Status
-------------
Users Logged In: $loggedinusers
Disk Space: $diskspace
Process Count: $processCount
Load Averages: $loadAverages
Memory Allocation:  $memoryAllocation
Listening Network Ports:  $listeningNetworkPorts
UFW Rules:$ufwRules

EOF
