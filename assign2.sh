#!/bin/bash
#changes the ip address
new_ip="192.168.1.21"
hostname=$HOSTNAME
echo "updating the ip address"
if grep -q "^$new_ip\t$hostname$" /etc/hosts; then
echo "IP Address for $hostname is already set to $new_ip."
else 
sed -i "/\\b$hostname\\b/s/[0-9.]*/$new_ip/" /etc/hosts
cat > /etc/netplan/10-yxc.yaml << EOF
network:
    version: 2
    ethernets:
        eth0:
            addresses: [192.168.1.21/24]
            routes:
              - to: default
                via: 192.168.16.2
            nameservers:
                addresses: [192.168.16.2]
                search: [home.arpa, localdomain]
        eth1:
            addresses: [172.16.1.200/24]
EOF
sudo netplan apply >/dev/null 2>&1
echo "updated succfully, ip now set to $new_ip."
fi

#checking if apache2 is installed and installing it if not
if ! dpkg -s apache2 > /dev/null 2>&1; then
echo "Apache2 is not installed. Installing ..."
sudo apt-get update >/dev/null
sudo apt-get install -y apache2 >/dev/null
if [ $? -eq 0 ]; then
echo "apache 2 has been installed"
else
echo "problem installing apache2"
fi
else
echo "Apache2 is already installed."
fi


#Checking if Squid is installed and if not installing it
if ! dpkg -s squid >/dev/null 2>&1; then
echo "Squid is not installed. Installing..."
sudo apt-get update >/dev/null
sudo apt-get install -y squid >/dev/null
if [ $? -eq 0 ]; then
echo "squid has been installed"
else
echo "problem installing squid"
fi
else
echo 'squid is already insalled'
fi
#checking if UFW is installed
if ! dpkg -s ufw >/dev/null 2>&1; then
echo "UFW is not installed. Installing..."
sudo apt-get update >/dev/null
sudo apt-get install -y ufw >/dev/null
else
echo "UFW is already installed."
fi




# Check and allow SSH (port 22)
echo "Allowing SSH only on the mgnt network..."
sudo ufw allow from 172.16.1.200/24 to any port 22



#Check and allow HTTP (port 80)
echo "Allowing HTTP..."
sudo ufw allow 80/tcp


# Check and allow web proxy (port 3128)
echo "allowing web proxy..."
sudo ufw allow 3128

#checks ufw status
ufw_status=$(sudo ufw status | grep -i "Status: active")
# enable UFW if it is not already enabled.
if [ -z "$ufw_status" ]; then
echo "UFW is not enabled Enabling"
sudo ufw --force enable
else
echo "UFW is already enabled."
fi

#reload ufw
sudo ufw reload
echo "Firewall config complete."
#checks if the user dennis exits and adds user if not
if id "dennis" > /dev/null 2>&1; then
echo "User dennis already exists"
else
useradd -m -s /bin/bash dennis
mkdir -p "/home/dennis"
fi
# checks if user dennis is already in the sudo group and adds him if not
if groups "dennis" | grep -q sudo; then
echo "User Dennis is already in the sudo group skipping..."
else
sudo usermod -a -G sudo "dennis"
if [ $? -eq -0 ]; then
echo "user dennis has been added to the sudo group"
else
echo "error adding user dennis to the sudo group"
fi
fi
# checks to see if dennis has a .ssh directory in his home directory and creates it if not
if [ -d "/home/dennis/.ssh" ]; then
echo "User dennis already has an .ssh directory."
else
mkdir -p /home/dennis/.ssh

fi

#checks if a authorised_keys file exists and creates it if not
echo "checking to see if the authorized_keys folder exists"
authorized_keys_file="/home/dennis/.ssh/authorized_keys"
if [ -f "$authorized_keys_file"  ]; then
echo "the authorized_keys folder exists skipping..."
else
echo "The authorized_keys file does not exist creating..."
touch  /home/dennis/.ssh/authorized_keys
fi 

# set ownership and permissons for authorized_keys"
chown "dennis:dennis" "/home/dennis/.ssh/authorized_keys"
chmod 600 "/home/dennis/.ssh/authorized_keys"

#sets the permissions and ownership of the .ssh directory
chmod 700 "/home/dennis/.ssh"
chown dennis:dennis /home/dennis/.ssh
# Generates a rsa & ed25519 SSH Key and puts in in the .ssh directory
sudo -u dennis ssh-keygen -t rsa -N "" -f /home/dennis/.ssh/id_rsa  >/dev/null 
sudo -u dennis ssh-keygen -t ed25519 -N "" -f /home/dennis/.ssh/id_ed25519 >/dev/null 



# puts the content of the previosly created public keys and puts them into the authorized_keys" file
cat "/home/dennis/.ssh/id_rsa.pub" >>  /home/dennis/.ssh/authorized_keys
cat "/home/dennis/.ssh/id_ed25519.pub" >> /home/dennis/.ssh/authorized_keys


# adds the given ssh-ed25519 public key provided to the .ssh/authorized_keys" file this allows the matching private key to authincate with the server.
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" > "/home/dennis/.ssh/authorized_keys"


#creates the rest of the users

users=(aubrey captain snibbles brownie scotter sandy perrier cindy tiger yoda)

for user in "${users[@]}"; do
user_home="/home"
user_ssh_dir=$user_home/$user/.ssh
#checks to make sure the user does not already exist
if id "$user" > /dev/null 2>&1; then
echo "User $user already exists, skipping..."
continue 
fi

#creates the user with a default shell
useradd -m -s /bin/bash "$user"

# Creates the user's home directory
mkdir -p "/home/$user"
# creats the .ssh folder if it does not already exist
if [ -d "$user_ssh_dir" ]; then
echo "User $user already has an .ssh directory."
else
mkdir -p $user_ssh_dir 

if [ $? -eq -0 ]; then
echo ".ssh directory for user $user created"
else
echo "error creating .ssh directory for user $user."
fi
fi
#creates the authorized_keys file
#checks if the authorized_keys directory exists and creates it if not
loop_authorized_keys_file="$user_home/$user/.ssh/authorized_keys"
if [ -f "$loop_authorized_keys_file" ]; then
echo "the authorized_keys folder exists skipping..."
else
echo "The authorized_keys file does not exist creating..."
touch $user_ssh_dir/authorized_keys
fi 
# set ownership and permissons for authorized_keys"
chown "$user:$user" "$user_ssh_dir/authorized_keys"
chmod 600 "$user_ssh_dir/authorized_keys"
#set ownership and permissions of the .ssh directory
chown "$user:$user" "$user_ssh_dir"
chmod 700 "$user_ssh_dir"
echo "user $user created succesfully."
#generates RSA & ED25519 keypair

sudo -u $user ssh-keygen -t rsa -N "" -f "$user_ssh_dir/id_rsa"  >/dev/null 
sudo -u $user ssh-keygen -t ed25519 -N "" -f "$user_ssh_dir/id_ed25519" >/dev/null 


cat $user_ssh_dir/id_rsa.pub >> "$user_ssh_dir/authorized_keys"
cat $user_ssh_dir/id_ed25519.pub >> "$user_ssh_dir/authorized_keys"
done