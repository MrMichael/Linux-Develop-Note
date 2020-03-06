import socket
import json
import requests
import os


def get_ip(master_ip):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect((master_ip, 1))
        IP = s.getsockname()[0]
    except:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP


master_ip = '10.201.0.1'
my_ip = get_ip(master_ip)
url = "http://{}:9000/internalapi/v1/worker/register".format(master_ip)

def try_register():
    try:
        res = requests.post(url, json.dumps({"ip": my_ip}), timeout=5)
    except:
        return False
    content = json.loads(str(res.content, encoding='utf-8'))
    data = content["data"]

    with open('/app/bootstrap/hosts.json', 'w') as outfile:
        json.dump(data["hosts"], outfile)

    os.chdir("/app")
    os.system("bootstrap/bootstrap.sh {} {} {} {} {}".format(
        my_ip,
        "bootstrap/hosts.json",
        data["adm_port"],
        master_ip,
        data["hostname"])
    )
    return True


while not try_register():
    pass

