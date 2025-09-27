#!/bin/bash

# Script di configurazione rete per Android Simulator 3

echo "🌐 Configurazione rete per Android Simulator 3..."

# Configura interfaccia di rete
ip addr add 172.20.3.10/24 dev eth0 2>/dev/null || true
ip route add default via 172.20.3.1 2>/dev/null || true

# Configura DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Abilita forwarding IP
echo 1 > /proc/sys/net/ipv4/ip_forward

# Configura iptables per NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT

echo "✅ Configurazione rete completata per Android 3"