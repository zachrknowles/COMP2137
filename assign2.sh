#!/bin/bash
new_ip="192.168.1.10"
echo "updating the ip address"
if grep -q "^$new_ip\t$HOSTNAME$" /etc/hosts; then
echo "IP Address for $HOSTNAME is already set to $new_ip."
exit 0
else 
sed -i "/\b$hostname\b/s/[0-9.]*/$new_ip/" /etc/hosts
fi


