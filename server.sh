cd ~
apt update
apt install shadowsocks-libev
apt install unzip
apt install python3-pyqrcode -y
apt install python3-flask -y
cd /etc/ssh
sed -i 's/#Port 22/Port 7077/' sshd_config
sed -i 's/#PermitTunnel no/PermitTunnel yes/' sshd_config
service sshd restart
cd ~
cp v2ray/ssconfig.json /etc/shadowsocks-libev/config.json
python3 v2ray.py &
git clone https://github.com/epg900/epfs2.git
cd epfs2
python3 server.py &
service shadowsocks-libev.service stop
service shadowsocks-libev.service start
ufw allow 9910
ufw allow 8088
ufw allow 1080

