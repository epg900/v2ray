#!/bin/bash
# IKEv2/IPsec PSK setup script with auto-generated PSK + QRCode

# خواندن آی‌پی سرور به صورت خودکار
SERVER_IP=$(hostname -I | awk '{print $1}')

# تولید PSK تصادفی (32 کاراکتر)
PSK_SECRET=$(openssl rand -base64 32)

# اینترفیس اینترنتی پیش‌فرض
NET_IFACE="eth0"

echo "[+] Installing strongSwan and qrencode..."
apt update && apt install -y strongswan iptables-persistent qrencode

echo "[+] Configuring ipsec.conf..."
cat > /etc/ipsec.conf <<EOF
config setup
  charondebug="ike 2, knl 2, cfg 2"

conn android
  keyexchange=ikev2
  auto=add
  left=${SERVER_IP}
  leftid=${SERVER_IP}
  leftauth=psk
  leftfirewall=yes
  right=%any
  rightid=%any
  rightauth=psk
  rightsourceip=0.0.0.0/0
EOF

echo "[+] Configuring ipsec.secrets..."
cat > /etc/ipsec.secrets <<EOF
${SERVER_IP} %any : PSK "${PSK_SECRET}"
EOF

echo "[+] Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

echo "[+] Setting up iptables NAT..."
iptables -t nat -A POSTROUTING -s 0.0.0.0/0 -o ${NET_IFACE} -j MASQUERADE
netfilter-persistent save

echo "[+] Restarting strongSwan..."
systemctl restart strongswan
systemctl enable strongswan

echo "[✓] IKEv2/IPsec PSK VPN setup completed!"
echo "Server IP: ${SERVER_IP}"
echo "Client subnet: 0.0.0.0/0 (all clients allowed)"
echo "Interface: ${NET_IFACE}"
echo "Generated PSK: ${PSK_SECRET}"

echo "[+] Showing PSK as QRCode:"
echo "${PSK_SECRET}" | qrencode -t ANSIUTF8
