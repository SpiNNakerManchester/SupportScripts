#!/bin/sh
# Copyright (c) 2017 The University of Manchester
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

# This script is called from Jenkins builds

REPO=$1
TARGET=$2

Branch=$(git ls-remote $REPO 2>/dev/null | awk '
    BEGIN {
    	id = "x"
    	# The next line is a default default only
    	branch = "REMOTE_PARSE_FAILED"
    	target_branch = "refs/heads/" ENVIRON["TRAVIS_BRANCH"]
    	target_tag = "refs/tags/" ENVIRON["TRAVIS_BRANCH"]
    }
    $2=="HEAD" {
    	# Note that the remote HEAD ref comes first
    	id = $1
    }
    $1==id {
    	sub(/refs\/(heads|tags)\//, "", $2)
    	branch = $2
    	# May be overwritten by the rule below; this is OK
    }
    $2==target_branch || $2==target_tag {
    	branch = ENVIRON["TRAVIS_BRANCH"]
    	# Reset the ID to a non-hash so the rule to match it will not fire
    	id = "x"
    }
    END {
    	print branch
    }')

git clone --branch $Branch $REPO $TARGET || exit $?
echo "checked out branch $Branch of $REPO"
