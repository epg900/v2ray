cd /root
apt update
apt install unzip -y
#apt install python3-flask -y
cd /etc/ssh
sed -i 's/#Port 22/Port 7077/' sshd_config
sed -i 's/#PermitTunnel no/PermitTunnel yes/' sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' sshd_config
service sshd restart
cd /root
git clone https://github.com/epg900/epfs2.git
cd /root
uuidcode=$(cat /proc/sys/kernel/random/uuid)
cd v2ray
unzip v2ray-linux-64.zip
export  V2RAY_VMESS_AEAD_FORCED=false
sed -i "s/uuid/$uuidcode/" config.txt
rm config.json
cp config.txt config.json
./v2ray run &
ipaddr=$(hostname -I | cut -d' ' -f1)
sed -i "s/uuid/$uuidcode/" config2.txt
sed -i "s/addr1/$ipaddr/" config2.txt
confb64=$(cat config2.txt | base64 -w 0)
conf="vmess://${confb64}"
echo $conf > config8.txt
#ss=$(echo "aes-128-gcm:e124" | base64 -w 0)
#ssconf="ss://${ss}@${ipaddr}:5055#ep"
#echo $ssconf >> config8.txt
curl -F file=@"config8.txt" https://epfs2.eu.pythonanywhere.com/uploader
curl -F file=@"config8.txt" https://epfa.pythonanywhere.com/uploadfiles
cp /root/v2ray/config8.txt /root/config8.txt
cd /root/epfs2
python3 server.py &
useradd ep -s /bin/false
passwd ep
passwd root
