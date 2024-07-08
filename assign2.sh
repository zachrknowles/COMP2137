#!/bin/bash
#changes the ip address
new_ip="192.168.1.21"
echo "updating the ip address"
if grep -q "^$new_ip\t$HOSTNAME$" /etc/hosts; then
echo "IP Address for $HOSTNAME is already set to $new_ip."
exit 0
else 
sed -i "/\b$hostname\b/s/[0-9.]*/$new_ip/" /etc/hosts
echo "updated succfully, ip now set to $new_ip."
fi

#checking if apache2 is installed and installing it if not
if ! dpkg -s apache2 > /dev/null 2>&1; then
echo "Apache2 is not installed. Installing ..."
sudo apt-get update 
sudo apt-get install -y apache2
else
echo "Apache2 is already installed."
fi


#Checking if Squid is installed and if not installing it
if ! dpkg -s squid >/dev/null 2>&1; then
echo "Squid is not installed. Installing..."
sudo apt-get install -y squid
else
echo 'squid is already insalled'
fi
