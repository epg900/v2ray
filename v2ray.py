# @title V2Ray Server
import json, base64, uuid, os, re, time
from IPython.display import HTML, clear_output
from threading import Timer
from subprocess import Popen , PIPE

!pip install pyqrcode
clear_output()
import pyqrcode

if os.path.isdir('server'):
  os.system('rm -r server')
os.system('mkdir server')

%cd server

!wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
clear_output()
!wget https://github.com/v2fly/v2ray-core/releases/download/v4.45.2/v2ray-linux-64.zip
clear_output()
!dpkg -i cloudflared-linux-amd64.deb
clear_output()
!unzip v2ray-linux-64.zip
clear_output()

os.remove("config.json")
idx=str(uuid.uuid4())
!chmod +x v2ray

config='{"log":{"access":"","error":"","loglevel":"warning"},"inbound":{"protocol":"vmess","port":%s,"settings":{"clients":[{"id":"%s","alterId":64}]},"streamSettings":{"network":"ws","security":"none"}},"inboundDetour":[],"outbound":{"protocol":"freedom","settings":{}}}' % (str(9910),idx)
with open("config.json", "w") as f:
  f.write(config)

clear_output()

!pkill v2ray
!pkill cloudflared

Popen("./v2ray run".split(), cwd='./', env={'V2RAY_VMESS_AEAD_FORCED':'false'})
Popen("cloudflared tunnel --url 127.0.0.1:9910 --logfile cloudflared.log".split(), stdout=PIPE, stdin=PIPE, stderr=PIPE, universal_newlines=True)
time.sleep(5)
ff=open("cloudflared.log", "r")
txt=ff.read()
ff.close()
addr=re.findall("https://(.*?.trycloudflare.com)",txt)

d=json.loads('{"add":"{0}","aid":"64","host":"","id":"{1}","net":"ws","path":"","port":"80","ps":"1","tls":"","type":"none","v":"2"}')
d["add"] = addr[0]
d["id"] = idx

clear_output()

print(json.dumps(d))

config="vmess://"+base64.b64encode(json.dumps(d).encode()).decode("utf-8")
#print(config)
url = pyqrcode.create(config)
url.svg('qrcode.svg', scale=8)
imgfile=base64.b64encode(open("qrcode.svg","rb").read()).decode('ascii')

display(HTML("<center><img width='270px' height='270px'  src='data:image/svg+xml;base64,{}' /></center>".format(imgfile)))
html_text = '''<center><input type="hidden" value="{}" id="clipborad-text">
                <button onclick="copyToClipboard()">Copy Config</button>
                <script>
                function copyToClipboard() {{
                    var copyText = document.getElementById("clipborad-text");
                    copyText.select();
                    navigator.clipboard.writeText(copyText.value);
                    alert("Copied the text: " + copyText.value);
                }}
                </script></center>'''.format(config)
display(HTML(html_text))
#time.sleep(7200)
while True: pass
