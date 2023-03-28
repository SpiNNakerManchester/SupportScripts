#!/bin/sh
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
