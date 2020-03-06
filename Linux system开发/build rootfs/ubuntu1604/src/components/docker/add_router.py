import requests
import json
import sys
import time


def format_data(ip):
    return json.dumps({
        "gw": ip,
        "ips": "172.{}.0".format(".".join(ip.split(".")[2:4])),
        "prefix": 24
    })


if len(sys.argv) != 4:
    print("bad args")
    exit(1)

local_ip = sys.argv[1]
hosts = sys.argv[2]
adm_port = sys.argv[3]

with open(hosts) as f:
    iplist = json.load(f)

executor = "http://{}:{}/api/v1/add_router"

# 0. ping localhost:adm_port/_ping
while True:
    try:
        r = requests.get(url="http://{}:{}/_ping".format(local_ip, adm_port))
        if r.status_code == 200:
            break
    except:
        pass
    time.sleep(1)

# 1. add others to localhost
for oip in iplist:
    requests.post(url=executor.format(
        local_ip, adm_port), data=format_data(oip))

# 2. add localhost to others
local = sys.argv[1]
for oip in iplist:
    requests.post(url=executor.format(oip, adm_port), data=format_data(local))
