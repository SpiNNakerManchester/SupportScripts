# Copyright (c) 2023 The University of Manchester
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

import sys
import requests
import tempfile
import os
import subprocess
from getpass import getpass
from xml.etree import ElementTree

base_uri = input("Base URI: ")

password = getpass()
if len(sys.argv) > 1:
    filename = sys.argv[1]
else:
    filename = input("Filename: ")

print(f"Downloading to: {filename}")

session = requests.Session()
session.post(
    f"{base_uri}/cgi/login.cgi",
    data={"name": "root", "pwd": password, "Login": "login"})
session.get(f"{base_uri}/cgi/Build_jnlp.cgi?time_stamp=1")
sid = session.cookies.get_dict()["SID"]

jnlp = session.get(f"{base_uri}/jnlp/sess_{sid}.jnlp")
jnlp_xml = ElementTree.ElementTree(
    ElementTree.fromstring(jnlp.content.decode()))
root = jnlp_xml.getroot()
root.set("codebase", base_uri)
app_desc = next(root.iter("application-desc"))
first_argument = next(app_desc.iter('argument'))
first_argument.text = "localhost"

jnlp_xml.write(filename)

print(f"File written to {filename}")
print("Attempting to open with javaws:")
try:
    pid = subprocess.Popen(["javaws", filename])
except:
    print(f"Execution failed - please launch {filename} manually using javaws")
