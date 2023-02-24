# Copyright (c) 2018 The University of Manchester
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

""" Get the "closest" git version to a given version on a given repository.

If the version is semantic formatted as <major>.<minor>.<patch> e.g. 4.0.1,
this will print a version with the same major version, and with a minor version
either the same or greater than the given minor version.  If a version with
the same patch version exists, this will be printed, otherwise a greater
patch number if possible, but if not, the greatest patch number is used.
If the same major version does not exist, or only minor versions less than
the minor version exist, master is printed.

If a non-semantic version is given, if a branch or tag exists with the version,
this is printed, otherwise master is printed.

If a third argument is given, this is taken as a version prefix to be used;
any semantic version will be assumed to have this prefix.
"""
from collections import defaultdict
import subprocess
import re
import sys
import os


def print_version(prefix, major, minor, patch):
    """ Print the version
    """
    print("{}{}.{}.{}".format(prefix, major, minor, patch))


# Get the arguments
repository = sys.argv[1]
version = sys.argv[2]
prefix = ""
if len(sys.argv) > 3:
    prefix = sys.argv[3]

# Check if the version is a semantic version
version_match = re.match(r"{}(\d+)\.(\d+)\.(\d+)".format(prefix), version)
if not version_match:

    # If not a semantic version, check if the branch or tag exists
    FNULL = open(os.devnull, 'w')
    result = subprocess.call(
        ["git", "ls-remote", "--exit-code", repository, version],
        stdout=FNULL, stderr=subprocess.STDOUT)
    if result == 0:
        print(version)
        sys.exit(0)

    # If it doesn't exist, return master
    print("master")
    sys.exit(0)

# If a semantic version, split in to parts
v_major = int(version_match.group(1))
v_minor = int(version_match.group(2))
v_patch = int(version_match.group(3))

# Run git ls-remote to get the list of branches and tags
git_process = subprocess.check_output(["git", "ls-remote", repository])
git_output = git_process.decode("utf-8")

# Extract versions that are semantic
pattern = re.compile(
    r"^[^\s]+\s+refs/(heads|tags)/{}(\d+)\.(\d+)\.(\d+)$".format(prefix))
versions = defaultdict(set)
for line in git_output.split("\n"):
    matcher = pattern.match(line)
    if matcher:
        major = int(matcher.group(2))
        minor = int(matcher.group(3))
        patch = int(matcher.group(4))
        versions[major].add((minor, patch))

# If the major version doesn't exist, assume master
if v_major not in versions:
    print("master")
    sys.exit(0)

# If the version exists exactly, return it
matching = versions[v_major]
if (v_minor, v_patch) in matching:
    print_version(prefix, v_major, v_minor, v_patch)
    sys.exit(0)

# Look through the versions that are minor and patch of the major
incomplete_match = None
for (minor, patch) in sorted(matching):

    # If the version is the same or higher, take it
    if (minor == v_minor and patch >= v_patch) or (minor > v_minor):
        print_version(prefix, v_major, minor, patch)
        sys.exit(0)

    # If the version is the same, but the patch is not higher, store for later
    elif minor == v_minor:
        incomplete_match = (minor, patch)

# If the only match was a minor without a patch, use it
if incomplete_match is not None:
    minor, patch = incomplete_match
    print_version(prefix, v_major, minor, patch)
    sys.exit(0)

# If no match, use master
print("master")
