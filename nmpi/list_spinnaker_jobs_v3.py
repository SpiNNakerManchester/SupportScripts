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
List all jobs that are SpiNNaker related in the NMPI queue.

Authentication parameters can be found in the config files on the server.
"""
import argparse
import requests

NMPI_URL = "https://nmpi-v3-staging.hbpneuromorphic.eu/jobs/"

parser = argparse.ArgumentParser()
parser.add_argument("username", help="The username to authenticate with")
parser.add_argument("token", help="The token to authenticate with")

args = parser.parse_args()
headers = {
    "x-api-key": args.token,
    "Content-Type": "application/json"
}

response = requests.get(NMPI_URL, headers=headers, verify=False)
job_list = response.json()

other = list()
for job in job_list:
    if "SPINNAKER" in job["hardware_platform"].upper():
        print("{}: {}: {}".format(
            job["hardware_platform"], job["id"], job["status"]))
    else:
        other.append(job)

print("\nOther jobs:")
for job in other:
    print("{}: {}: {}".format(
        job["hardware_platform"], job["id"], job["status"]))
