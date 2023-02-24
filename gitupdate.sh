#!/bin/bash

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

# This script assumes it is run from the directory holding all github projects in parellel
# sh SupportScripts/gitupdate.sh a_branch_name

# checks a branch found locally
# May try to merge but exits on a conflict
check_remove(){
	if [ $1 = "master" ]; then 
		return 
	fi
	# if the remote brnach exist update the local branch with master and the remote branch
	if git ls-remote --heads | grep -sw $1>/dev/null; then
		echo $1 Still on remote
		git checkout $1
		git merge -m"merged in remote/$1" refs/remotes/origin/$1 || exit -1
		git merge -m"merged in master" refs/remotes/origin/master || git merge -m"merged in main" refs/remotes/origin/main || exit -1
		git checkout -q master
		return
	fi
	# Check if the local branch has been fully merged into master
	if git merge-base --is-ancestor refs/heads/$1 refs/remotes/origin/master; then
	    # check the local branch has falled behind master
		if git merge-base --is-ancestor refs/remotes/origin/master refs/heads/$1 ; then
		        # Same as Master so probably a new branch
		     	echo $1 Same as Master
		else
		    # behind master so assumed no longer required
			git branch -d $1 || exit -1
			echo $1 deleted
		fi
	# Check if the local branch has been fully merged into master
	elif git merge-base --is-ancestor refs/heads/$1 refs/remotes/origin/main; then
	    # check the local branch has falled behind master
		if git merge-base --is-ancestor refs/remotes/origin/main refs/heads/$1 ; then
		        # Same as Main so probably a new branch
		     	echo $1 Same as Main
		else
		    # behind main so assumed no longer required
			git branch -d $1 || exit -1
			echo $1 deleted
		fi
	else
	    # Never automaically delete a branch which has not been committed
		echo $1 not merged
	fi
}


update(){
	cd $1 || return
	echo
	pwd
	if [ -d .git ]; then
	    # update master
	    git fetch
	    git checkout -q master || git checkout -q main || exit -1
	    git merge -m "merged in remote master" refs/remotes/origin/master || git merge -m "merged in remote main" refs/remotes/origin/main  || exit -1
	    # git gc --prune=now || exit -1
	    # check each local branch
	    for branch in $(git for-each-ref --format='%(refname)' refs/heads/); do
	        echo ${branch:11}
		    check_remove ${branch:11}
	    done
	    # switch back to master and then if available the branch selected
        git checkout -q master || git checkout -q main
	    if [ -n "$2" ]; then
            git checkout -q $2
        fi
	else
	    echo "Not a git repsoitory"
	fi
	cd ..
}

for D in *; do
	if [ -d "${D}" ]; then
        update "${D}" $1 
    fi
done

