#!/bin/bash

# This script does a quick and dirty install of the puppet8 agent on ubuntu 22.04 systems for the lab
# It has a hard-coded IP address for the hostvm
# It requests a certificate from the puppet server blindly and will wait around in the background until it gets one

echo "Adding puppet server to /etc/hosts file if necessary"
grep -q ' puppet$' /etc/hosts || sudo sed -i -e '$a172.16.1.1 puppet' /etc/hosts

echo 'Setting up for puppet8 and installing agent on $(hostname)'
wget -q https://apt.puppet.com/puppet8-release-jammy.deb
dpkg -i puppet8-release-jammy.deb
apt-get -qq update

echo "Restarting snapd.seeded.service can take a long time, do not interrupt it - installing puppet agent"
NEEDRESTART_MODE=a apt-get -y install puppet-agent >/dev/null

echo "Setting up PATH to include puppet tools"
echo 'export PATH=$PATH:/opt/puppetlabs/bin' >> ~/.bashrc
source ~/.bashrc

echo "Requesting a certificate from puppet master - run:
sudo /opt/puppetlabs/bin/puppetserver ca sign --all
on the puppet master to complete the request"

/opt/puppetlabs/bin/puppet ssl bootstrap &

