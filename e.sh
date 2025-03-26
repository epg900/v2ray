cd /etc/ssh
sed -i 's/#Port 22/Port 7077/' sshd_config
sed -i 's/#PermitTunnel no/PermitTunnel yes/' sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' sshd_config
service sshd restart
useradd ep -s /bin/false
passwd ep
passwd root
