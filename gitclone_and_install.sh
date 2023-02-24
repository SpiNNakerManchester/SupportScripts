#!/bin/sh

# Copyright (c) 2020 The University of Manchester
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

# Oulls from github either the cureent branch or master
# Then installs it.
# Works for a github push action but not a pull_request
REPO=$1
GIT_PATH=https://github.com/SpiNNakerManchester/${REPO}.git
echo $GITHUB_REF
Branch=$(git ls-remote $GIT_PATH | awk '
    BEGIN {
    	branch = "master"
    	target = ENVIRON["GITHUB_REF"]
    }
    $2==target {
    	branch = ENVIRON["GITHUB_REF"]
    }
    END {
    	print branch
    }')

Branch=${Branch#refs/heads/}
git clone --branch $Branch $GIT_PATH || exit $?
echo "checked out branch $Branch of $GIT_PATH"
cd ${REPO}
pwd
python setup.py install