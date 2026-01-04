cd /root
apt update
apt install shadowsocks-libev -y
apt install unzip -y
apt install python3-flask -y
cd /etc/ssh
sed -i 's/#Port 22/Port 7077/' sshd_config
sed -i 's/#PermitTunnel no/PermitTunnel yes/' sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' sshd_config
service sshd restart
cd /root
cp v2ray/ssconfig.json /etc/shadowsocks-libev/config.json
git clone https://github.com/epg900/epfs2.git
cd /root
#cat /proc/sys/kernel/random/uuid
service shadowsocks-libev stop
service shadowsocks-libev start
ufw allow 9910
ufw allow 8088
ufw allow 1080
cd v2ray
python3 v2ray.py
export  V2RAY_VMESS_AEAD_FORCED=false
./v2ray run &
python3 -m http.server &
curl -F file=@"config7.txt" https://epfs2.eu.pythonanywhere.com/uploader
curl -F file=@"config7.txt" https://epfa.pythonanywhere.com/uploadfiles
cp /root/v2ray/config7.txt /root/config7.txt
cd /root/epfs2
python3 server.py &
useradd ep -s /bin/false
passwd ep
passwd root

