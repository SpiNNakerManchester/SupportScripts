#!/bin/sh

# Copyright (c) 2018 The University of Manchester
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

function git_sync {
	[ -d $1/.git ] && (
		echo "Synchronising $1..."
		cd $1
		for remote in `git remote`; do
			git fetch $remote && git remote prune $remote
		done
	)
}

if [ -n "$1" ] && [ "$1" = "-h" -o "$1" = "-help" -o "$1" = "--help" ]; then
	echo "Usage: $0 ?-help? ?BASEDIR?"
	echo ""
	echo "This script synchronises all git repositories within the given BASEDIR"
	echo "(or the current directory if that is not specified). A repository is"
	echo "synchronised if all of its remote branches are in the same state as the"
	echo "corresponding branch on each remote (typically called 'origin')."
	echo ""
	echo "The -help option (also -h and --help) prints this message."
	exit
fi
if [ -n "$1" ] && [ -d "$1" ]; then
	cd "$1"
fi
for dir in *; do
	git_sync ${dir}
done
