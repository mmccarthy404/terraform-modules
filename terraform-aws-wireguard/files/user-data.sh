#!/bin/bash

# Update system and install necessary packages
apt-get update
apt-get install -y wireguard wireguard-tools iptables

# Set up WireGuard configuration
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = ${interface_private_key}
Address = ${interface_address}
ListenPort = ${interface_listen_port}
DNS = ${interface_dns}

PostUp = ${interface_post_up}
PostDown = ${interface_post_down}

[Peer]
PublicKey = ${peer_public_key}
AllowedIPs = ${peer_allowed_ip}
EOF

# Enable IP forwarding in the kernel
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Enable and start WireGuard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0