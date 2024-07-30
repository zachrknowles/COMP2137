#! /bin/bash

verbose=false

while getopts ":verbose:name:ip:hostentry:" opt; do
case $opt in
verbose) verbose=true ;;
name) desired_name="$OPTARG" ;;
ip) desired_ip="$OPTARG" ;;
hostentry) desired_named="$OPTARG"; desired_ip="$OPTARG" ;;
/? echo "Invalid option:" -$OPTARG >&2; exit 1 ;;
esac
done

print_message(){
if [[ "$verbose" == true ]]; then
  echo $1
fi
}

print_error() {
echo "Error: $1" >&2
}

update_hostname(){
currentname=$(hostname)

if [[ "$desired_name" != "$current_name" ]]; then
  print_message "Updating hostname from '$current_name' to '$desired_name'"
  sudo hostnamectl set-hostname "$desired_name"
  sudo sed -i "s/$current_name/$desired_name/g" /etc/hosts
  if [[ $? -eq 0]]; then
    print_messgae "Hostname updated successfully."
  else
  print_error "Error updating hostname in /etc/hosts"
  exit 1
fi
else
  print_message "Hostname '$desired_name' already set."
fi
}
update_ip(){
    interface="eth0"
    
    current_ip=$(ip addr show $interface | grep 'inet ' | cut -d ' ' -f2 | cut -d'/' -f1)
    if [[ "$desired_ip" != "$current_ip"]]; then
    print_message "Updating IP address on interface '$interface' from '$current_ip' to '$desired_ip'"
    netplan_config=$(ls /etc/netplan/*.yaml | head -n 1)
    if [[ -z "$netplan_config" ]]; then
    print_error "Could not find the Netplan configuration file."
    exit 1
  fi
  sudo netplan edit
  sei -i "/^ addresses:/a/   addresses: ['$desired_ip'/24']" "$netplan_config"
  sudo netplan apply
  if [[ $? -eq 0]]; then
    print_message "IP Address updated Successfully."
  else
    print_error "Error updating IP Address using netplan"
  exit 1
fi
else
  print_message "IP Address '$desired_ip' already set on interface '$interface'."
fi
}
update_hosts_entry(){
current_entry=$(grep -E "^$disered_name/s+$desired_ip" /etc/hosts)

if [[ -z "$curret_entry"]]; then\
  print_message "adding entry '$desired_name $desired_ip' to /etc/hosts"
  echo "$desired_ip $desired_name" | sudo tee -a /etc/hosts
  if [[?$ -eq 0 ]]; then 
    print_message "hosts entry adde successfully."
  else
    print_error "error adding entry to /etc/hosts."
    exit 1
fi
else
  print_message "entry '$desired_name $desired_ip' already exists in /etc/hosts."
fi
}
if [[ "$verbose" == true ]]; then
  print_message "running in verbose mode."
fi
if [[ -n "$desired_name" ]]; then
  update_hostname
fi

if [[ -n "$desired_ip" ]]; then
  update_ip
fi
if [[ -n "$desired_name" && -n "$desired_ip" ]]; then
  update_hosts_entry
fi

exit 0