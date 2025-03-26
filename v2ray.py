import json, base64, uuid, os, re, time, sys
from threading import Timer
from subprocess import Popen , PIPE

import socket
import fcntl
import struct
#import pyqrcode

def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])

serverip = get_ip_address(b'eth0')

#Popen("wget https://github.com/v2fly/v2ray-core/releases/download/v4.45.2/v2ray-linux-64.zip".split())
Popen("wget https://github.com/epg900/v2ray/blob/main/v2ray-linux-64.zip".split())
time.sleep(2)
os.system("unzip v2ray-linux-64.zip")
time.sleep(4)
os.remove("config.json")
idx=str(uuid.uuid4())
Popen("chmod +x v2ray".split())

config='{"log":{"access":"","error":"","loglevel":"warning"},"inbound":{"protocol":"vmess","port":%s,"settings":{"clients":[{"id":"%s","alterId":64}]},"streamSettings":{"network":"ws","security":"none"}},"inboundDetour":[],"outbound":{"protocol":"freedom","settings":{}}}' % (str(9910),idx)
with open("config.json", "w") as f:
  f.write(config)

Popen("pkill v2ray".split())

#Popen("./v2ray run".split(), cwd='./', env={'V2RAY_VMESS_AEAD_FORCED':'false'})

d=json.loads('{"add":"{0}","aid":"64","host":"","id":"{1}","net":"ws","path":"","port":"9910","ps":"1","tls":"","type":"none","v":"2"}')
d["add"] = serverip
d["id"] = idx

print(json.dumps(d))

config="vmess://"+base64.b64encode(json.dumps(d).encode()).decode("utf-8")
ssconf="ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTplMTI0@"+str(serverip)+":8088#ep"
#url = pyqrcode.create(config)
#url.svg('qrcode.svg', scale=8)
with open("config7.txt", "w") as f:
  f.write(config)
  f.write("\n")
  f.write(ssconf)

print(config)
print(ssconf)
#print("\n\n")
#print(url.terminal(quiet_zone=1))

