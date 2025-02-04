#!/bin/bash -ex
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Enable ip_forward to allow advertising routes
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# Install tailscale
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://pkgs.tailscale.com/stable/amazon-linux/2/tailscale.repo
sudo yum install -y tailscale

# Setup tailscale
sudo systemctl enable --now tailscaled

# Wait a few for tailscaled to come up
sleep 5

# Start tailscale
sudo tailscale up \
    --advertise-routes=${routes} \
    --authkey=${authkey} \
    --hostname=${hostname}
