#!/bin/bash

# Script per configurare le reti separate per i 3 dispositivi Android

echo "🌐 Configurazione reti separate per simulatori Android"
echo "====================================================="

# Abilita forwarding IP
echo "📡 Abilitazione IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# Crea bridge per ogni dispositivo
echo "🌉 Creazione bridge di rete..."

# Bridge per Android 1
ip link add name android1-br type bridge
ip addr add 172.20.1.1/24 dev android1-br
ip link set android1-br up

# Bridge per Android 2  
ip link add name android2-br type bridge
ip addr add 172.20.2.1/24 dev android2-br
ip link set android2-br up

# Bridge per Android 3
ip link add name android3-br type bridge
ip addr add 172.20.3.1/24 dev android3-br
ip link set android3-br up

# Configura iptables per NAT
echo "🔧 Configurazione NAT..."

# Android 1
iptables -t nat -A POSTROUTING -s 172.20.1.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -i android1-br -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o android1-br -j ACCEPT

# Android 2
iptables -t nat -A POSTROUTING -s 172.20.2.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -i android2-br -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o android2-br -j ACCEPT

# Android 3
iptables -t nat -A POSTROUTING -s 172.20.3.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -i android3-br -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o android3-br -j ACCEPT

# Salva configurazione iptables
echo "💾 Salvataggio configurazione iptables..."
iptables-save > /etc/iptables/rules.v4

echo "✅ Configurazione rete completata!"
echo ""
echo "📋 Reti configurate:"
echo "   Android 1: 172.20.1.0/24 (bridge: android1-br)"
echo "   Android 2: 172.20.2.0/24 (bridge: android2-br)" 
echo "   Android 3: 172.20.3.0/24 (bridge: android3-br)"
echo ""
echo "🔧 Per rendere permanente la configurazione:"
echo "   sudo systemctl enable iptables"
echo "   sudo systemctl start iptables"
