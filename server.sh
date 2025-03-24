cd ~
apt update
apt install shadowsocks-libev -y
apt install unzip -y
apt install python3-pyqrcode -y
apt install python3-flask -y
cd /etc/ssh
sed -i 's/#Port 22/Port 7077/' sshd_config
sed -i 's/#PermitTunnel no/PermitTunnel yes/' sshd_config
service sshd restart
cd ~
cp v2ray/ssconfig.json /etc/shadowsocks-libev/config.json
git clone https://github.com/epg900/epfs2.git
cd ~
python3 -m http.server &
service shadowsocks-libev stop
service shadowsocks-libev start
ufw allow 9910
ufw allow 8088
ufw allow 1080
cd v2ray
python3 v2ray.py
export  V2RAY_VMESS_AEAD_FORCED=false
./v2ray run &

