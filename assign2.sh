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
sudo apt-get install -y apache2 >/dev/null
else
echo "Apache2 is already installed."
fi


#Checking if Squid is installed and if not installing it
if ! dpkg -s squid >/dev/null 2>&1; then
echo "Squid is not installed. Installing..."
sudo apt-get install -y squid >/dev/null
else
echo 'squid is already insalled'
fi
#checking if UFW is installed
if ! dpkg -s ufw >/dev/null 2>&1; then
echo "UFW is not installed. Installing..."
sudo apt-get update
sudo apt-get install -y ufw >/dev/null
else
echo "UFW is already installed."
fi

#checks ufw status
ufw_status=$(ufw status verbose |grep -i 'Status active')

if [[ -z '$ufw_status' ]]; then
echo "UFW is not enabled Enabling"
sudo "UFW is already enabled."
else
echo "UFW is already enabled."
fi

# Check and allow SSH (port 22)
if ! ufw status | grep -q "\<OpenSSH\>"; then
echo "Allowing SSH.."
sudo ufw allow 22
else
echo "port 22 already allowed skipping..."
fi

#Check and allow HTTP (port 80)
if ! ufw status | grep -q "\<http\>" then
echo "Allowing HTTP..."
sudo ufw allow 80
else
echo "port 80 already allowed skipping..."
fi

# Check and allow web proxy (port 3128)
if ! ufw status | grep -q "\www\>" then
echo "allowing web proxy..."
sudo ufw allow 3128
else
echo "port 3128 already allowed skipping..."
fi
echo "Firewall config complete."