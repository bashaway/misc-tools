#!/usr/bin/env python3
import requests
import json
import datetime

date = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
status = {'date': date}

url = "https://status.slack.com/api/v2.0.0/current"
res = requests.get(url)
data = json.loads(res.text)
if data['status'] == 'ok':
  status.update({'slack': 'True'})
else:
  status.update({'slack': 'False'})

url = "https://status.dev.azure.com/_apis/status/health";
res = requests.get(url)
data = json.loads(res.text)
if data['status']['health'] == 'healthy':
  status.update({'AzureDevOps': 'True'})
else:
  status.update({'AzureDevOps': 'False'})

print(status)

