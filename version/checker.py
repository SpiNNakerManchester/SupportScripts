# Copyright (c) 2017 The University of Manchester
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

import os

path = __file__
code_directory = os.path.dirname(path)
module_directory = os.path.dirname(code_directory)
root_directory = os.path.dirname(module_directory)

versions = {}


def get_version(module):
    module_directory = os.path.join(root_directory, module)
    if not os.path.exists(module_directory):
        print("{} DIRECTORY NOT FOUND".format(module_directory))

    setup_path = os.path.join(module_directory, "setup.py")
    main_package = find_main_package(setup_path)
    name = find_name(setup_path)
    check_versions(setup_path)
    requirements_path = os.path.join(module_directory, "requirements.txt")
    check_versions(requirements_path)
    main_directory = os.path.join(module_directory, main_package)
    version_path = os.path.join(main_directory, "_version.py")
    version = find_version(version_path)
    if version != VERSION:
        raise version_file(f"Found version {version} in {module}")
    print(module, main_package, version, name)
    versions[name] = version


def find_main_package(setup_file):
    with open(setup_file, 'r') as f:
        for line in f:
            if "main_package = " in line:
                parts = line.split("\"")
                # print parts
                return parts[1]
    if setup_file.endswith('/sPyNNaker/setup.py'):
        return "spynnaker"
    if setup_file.endswith('/spalloc/setup.py'):
        return "spalloc"
    raise ValueError("Unable to find main_package = in {}".format(setup_file))


def find_name(setup_file):
    with open(setup_file, 'r') as f:
        for line in f:
            if "name=" in line:
                parts = line.split("\"")
                # print parts
                return parts[1]
    raise ValueError("Unable to find name= in {}".format(setup_file))


def find_version(version_file):
    with open(version_file, 'r') as f:
        for line in f:
            if "__version__" in line:
                parts = line.split("\"")
                # print parts
                return parts[1]
    raise ValueError("Unable to find__version__ in {}".format(version_file))


def check_versions(file):
    for name, version in versions.items():
        with open(file, 'r') as f:
            for line in f:
                if name in line:
                    check_version(line, name, version, file)


def check_version(line, name, version, file):
    line = line.strip(" \t\n\r',[]")
    if line.startswith("install_requires"):
        line = line[16:]
        line = line.strip(" \t\n\r',[]")
    if line.startswith("="):
        line = line[1:]
        line = line.strip(" \t\n\r',[]")
    # check in case sPyNNaker7.. or sPyNNaker8..
    if "#" in line:
        return  # comment
    if line[:4] == "name":
        return
    if line[:3] == "url":
        return
    seven_eight = line[len(name)]
    if seven_eight == "7" or seven_eight == "8":
        return
    parts = line.split(" ")
    parts[2] = parts[2].strip(",")
    if parts[2] != version:
        raise ValueError("Version mismatch in {} found {} expected {} {} in "
                         "File \"{}\"".format(file, line, name, version, file))

VERSION = "1!6.0.0"
print(root_directory)
get_version("SpiNNUtils")
get_version("SpiNNMachine")
get_version("SpiNNMan")
get_version("DataSpecification")
get_version("PACMAN")
get_version("spalloc")
get_version("testbase")
get_version("SpiNNFrontEndCommon")
get_version("SpiNNakerGraphFrontEnd")
get_version("sPyNNaker")
get_version("sPyNNakerNewModelTemplate")
print(versions)
