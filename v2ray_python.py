# @title V2Ray Server
import json, base64, uuid, os, re, time, sys, webbrowser
from IPython.display import HTML, clear_output
from threading import Timer
from subprocess import Popen , PIPE

Popen("pip install pyqrcode".split())
time.sleep(4)
import pyqrcode

if os.path.isdir('server'):
  os.system('rm -r server')
os.system('mkdir server')

os.system("cd server")

Popen("wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64".split())
time.sleep(2)
Popen("chmod +x cloudflared-linux-amd64".split())
Popen("wget https://github.com/v2fly/v2ray-core/releases/download/v4.45.2/v2ray-linux-64.zip".split())
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
Popen("pkill cloudflared".split())

Popen("./v2ray run".split(), cwd='./', env={'V2RAY_VMESS_AEAD_FORCED':'false'})
Popen("./cloudflared-linux-amd64 tunnel --url 127.0.0.1:9910 --logfile cloudflared.log".split(), stdout=PIPE, stdin=PIPE, stderr=PIPE, universal_newlines=True)
time.sleep(5)
ff=open("cloudflared.log", "r")
txt=ff.read()
ff.close()
addr=re.findall("https://(.*?.trycloudflare.com)",txt)

d=json.loads('{"add":"{0}","aid":"64","host":"","id":"{1}","net":"ws","path":"","port":"80","ps":"1","tls":"","type":"none","v":"2"}')
d["add"] = addr[0]
d["id"] = idx

print(json.dumps(d))

config="vmess://"+base64.b64encode(json.dumps(d).encode()).decode("utf-8")

url = pyqrcode.create(config)
url.svg('qrcode.svg', scale=8)
print(url.terminal(quiet_zone=1))
try:
  webbrowser.open('qrcode.svg')
  subprocess.call(('xdg-open','e.pishvaz.jpg'))
except Exception as e :
  e = sys.exc_info()
  print(e[1])

