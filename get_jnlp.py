import sys
import requests
import tempfile
import os
import subprocess
from getpass import getpass
from xml.etree import ElementTree

password = getpass()
if len(sys.argv) > 1:
    filename = sys.argv[1]
else:
    filename = input("Filename: ")

print(f"Downloading to: {filename}")

session = requests.Session()
session.post(
    "http://localhost:8080/cgi/login.cgi",
    data={"name": "root", "pwd": password, "Login": "login"})
session.get("http://localhost:8080/cgi/Build_jnlp.cgi?time_stamp=1")
sid = session.cookies.get_dict()["SID"]

jnlp = session.get(f"http://localhost:8080/jnlp/sess_{sid}.jnlp")
jnlp_xml = ElementTree.ElementTree(
    ElementTree.fromstring(jnlp.content.decode()))
root = jnlp_xml.getroot()
root.set("codebase", "http://localhost:8080/")
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