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
import inspect
import subprocess
from getpass import getpass
from xml.etree import ElementTree

current_script_path = os.path.dirname(inspect.getfile(inspect.currentframe()))
print(current_script_path)

base_uri = input("Base URI: ")

password = getpass()
if len(sys.argv) > 1:
    filename = sys.argv[1]
else:
    filename = input("Filename: ")

print(f"Making: {filename}")

session = requests.Session()
session.post(
    f"{base_uri}/cgi/login.cgi",
    data={"name": "root", "pwd": password, "Login": "login"})
session.get(f"{base_uri}/cgi/Build_jnlp.cgi?time_stamp=1")
sid = session.cookies.get_dict()["SID"]

print(f"Session: {sid}")

jnlp_xml = ElementTree.parse("template.jnlp")
root = jnlp_xml.getroot()
root.set("codebase", f"file://{current_script_path}")
app_desc = root.find("application-desc")
args = app_desc.findall('argument')
args[1].text = sid
args[2].text = sid

jnlp_xml.write(filename)

print(f"File written to {filename}")
print("Attempting to open with javaws:")
try:
    pid = subprocess.Popen(["javaws", filename])
except:
    print(f"Execution failed - please launch {filename} manually using javaws")
