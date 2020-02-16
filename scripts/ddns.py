#!/usr/bin/env python3

import requests
import json
import subprocess

home = "/home/pi/"

with open(home+'homeassistant/scripts/ddns_settings.json') as json_file:
    data = json.load(json_file)
    email = data["email"]
    authKey = data["authKey"]
    domain = data["domain"]
    zone = data["zone"]


req = requests.get('https://api.ipify.org?format=json')

currentIp = req.json()["ip"]
lastIp = subprocess.run(['cat', home+'/lastIp'], stdout=subprocess.PIPE).stdout.decode('utf-8').strip()

print("Current IPv4 = " + currentIp)
print("Previous IPv4 = " + lastIp)

def update(zone, domain):
    header = {"X-Auth-Key": authKey, "X-Auth-Email": email, "Content-Type":"application/json"}
    req = requests.get("https://api.cloudflare.com/client/v4/zones/", headers=header)
    zones = req.json()
    for result in zones["result"]:
        if(result["name"] == zone):
            print("Connected to zone "+result["name"])
            req = requests.get("https://api.cloudflare.com/client/v4/zones/"+result["id"]+"/dns_records?type=A", headers=header)
            for dns in req.json()["result"]:
                print("Checking dns record "+dns["name"])
                if(dns["name"].startswith(domain)):
                    d = json.dumps({"type":"A", "name":dns["name"], "content":currentIp})
                    req = requests.put("https://api.cloudflare.com/client/v4/zones/"+result["id"]+"/dns_records/"+dns["id"], headers=header, data=d)
                    print(req.json())
                    if req.status_code == 200 :
                        print("Succesfully updated DNS record")
                        with open(home+"lastIp", "w") as file:
                            file.write(currentIp)

if(currentIp == ""):
    print("No IP has been provided")
    exit()
if(currentIp != lastIp):
    print("Ip has changed!")
    print("Updating DNS...")
    update(domain, zone)
else:
    print("Ip has not been changed")