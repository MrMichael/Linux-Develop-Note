import json
import sys
import os
from shutil import copyfile


args = len(sys.argv)

if args < 2:
    print("bad args")
    exit(-1)
elif args == 2:
    daemon_path = "./daemon.json"
else:
    daemon_path = sys.argv[2]

with open(daemon_path) as f:
    d = json.load(f)

copyfile(daemon_path, daemon_path + ".bak")
d["bip"] = sys.argv[1]

with open(daemon_path, "w") as f:
    json.dump(d, f, indent=4)
