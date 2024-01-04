# Copyright (c) 2021 The University of Manchester
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Set a job from the queue to "Error" status.

Authentication parameters can be found in the config files on the server.
"""
import argparse
import requests

NMPI_URL = "https://nmpi.hbpneuromorphic.eu/api/v2/queue/{}"
NMPI_LOG_URL = "https://nmpi.hbpneuromorphic.eu/api/v2/log/{}"

parser = argparse.ArgumentParser()
parser.add_argument("job", help="The Job ID")
parser.add_argument("username", help="The username to authenticate with")
parser.add_argument("token", help="The token to authenticate with")
parser.add_argument("reason", help="The reason for the shutdown")

args = parser.parse_args()
headers = {
    "Authorization": "ApiKey {}:{}".format(args.username, args.token),
    "Content-Type": "application/json"
}

log_url = NMPI_LOG_URL.format(args.job)
response = requests.get(log_url, headers=headers)
if response.status_code == 404:
    log = dict()
    log["content"] = args.reason
    response = requests.put(log_url, json=log, headers=headers)
    print("Log update response:", response)
else:
    log = response.json()
    log["content"] += "\\n" + args.reason
    response = requests.put(log_url, json=log, headers=headers)
    print(log)
    print("Log update response:", response)

job_url = NMPI_URL.format(args.job)
response = requests.get(job_url, headers=headers)
job = response.json()
print(job)

job["status"] = "error"
put_response = requests.put(job_url, json=job, headers=headers)
print("Job update response:", put_response)
