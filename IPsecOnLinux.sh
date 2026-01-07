#!/bin/bash
# IKEv2/IPsec PSK setup script with auto-generated PSK + QRCode

SERVER_IP=$(hostname -I | awk '{print $1}')

PSK_SECRET="eE!12345"
#$(openssl rand -base64 32)

read -p "Enter eth0 : " eth
read -p "Enter Client IP range : " iprange
NET_IFACE=$eth

apt update && apt install -y strongswan iptables-persistent 

cat > /etc/ipsec.conf <<EOF
config setup
  charondebug="ike 2, knl 2, cfg 2"

conn android
  keyexchange=ikev2
  ike=aes128-sha1-modp1024
  esp=aes128-sha1
  #auto=add
  left=${SERVER_IP}
  leftid=${SERVER_IP}
  leftauth=psk
  leftfirewall=yes
  right=%any
  rightid=%any
  rightauth=psk
  rightsourceip=$iprange
EOF

cat > /etc/ipsec.secrets <<EOF
${SERVER_IP} %any : PSK "${PSK_SECRET}"
EOF

sysctl -w net.ipv4.ip_forward=1
sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

iptables -t nat -A POSTROUTING -s $iprange -o ${NET_IFACE} -j SNAT --to-source ${SERVER_IP} 
netfilter-persistent save

echo "[+] Restarting strongSwan..."
systemctl restart  strongswan-starter.service
systemctl enable  strongswan-starter.service

#echo "${PSK_SECRET}" | qrencode -t ANSIUTF8



