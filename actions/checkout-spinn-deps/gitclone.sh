#!/bin/sh
# Copyright (c) 2020 The University of Manchester
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

# This workflow will install Python dependencies, run tests, lint and rat with a variety of Python versions
# For more information see: https://help.github.com/actions/language-and-framework-guides/using-python-with-github-actions

# This script works when called from a github action on PUSH not for PULL_REQUEST

REPO=$1

Branch=$(git ls-remote $REPO 2>/dev/null | awk '
    BEGIN {
    	id = "x"
    	# The next line is a default default only
    	branch = "REMOTE_PARSE_FAILED"
    	target = ENVIRON["GITHUB_REF"]
    }
    $2=="HEAD" {
    	# Note that the remote HEAD ref comes first
    	id = $1
    }
    $1==id {
    	branch = $2
    	# May be overwritten by the rule below; this is OK
    }
    $2==target {
    	branch = target
    	# Reset the ID to a non-hash so the rule to match it will not fire
    	id = "x"
    }
    END {
    	sub(/refs\/(heads|tags)\//, "", branch)
    	print branch
    }')

git clone --depth 1 --branch $Branch $REPO || exit $?
echo "checked out branch $Branch of $REPO"
