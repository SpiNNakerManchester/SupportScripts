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
