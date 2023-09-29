#!/bin/bash

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

# This script assumes it is run from the directory holding all github projects in parellel
# sh SupportScripts/gitupdate.sh a_branch_name any_thing_as_a_do_all_flag

# checks a branch found locally
# May try to merge but exits on a conflict
check_remove(){
  echo branch $1 main $2
	if [ $1 = $2 ]; then
		return 
	fi
	# if the remote branch exist update the local branch with master and the remote branch
	if git ls-remote --heads | grep -sw $1>/dev/null; then
		echo $1 Still on remote
		git checkout $1
		git merge -m"merged in remote/$1" refs/remotes/origin/$1 || exit -1
		git merge -m"merged in $2" refs/remotes/origin/$2 || exit -1
		git checkout -q master
		return
	else
	  echo no remote
	fi
	# Check if the local branch has been fully merged into master
	if git merge-base --is-ancestor refs/heads/$1 refs/remotes/origin/$2; then
    # check the local branch has falled behind master
		if git merge-base --is-ancestor refs/remotes/origin/master refs/heads/$1 ; then
		        # Same as Master so probably a new branch
		     	echo $1 Same as $2
		else
		    # behind master so assumed no longer required
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
	echo # A blank line
	pwd  # print the directory
	echo $(git for-each-ref --format='%(refname)' refs/remotes/origin/heads/)
	main="NO Main"
	for branch in $(git for-each-ref --format='%(refname)' refs/heads/); do
    name=${branch:11}
    if [ ${name} = "master" ] || [ ${name} = "main" ]; then
      main=${name}
    fi
	done
	#echo main = ${main}
	if [ -d .git ]; then
	    # update master
	    git fetch
	    git checkout -q $main || exit -1
	    git merge -m "merged in remote master" refs/remotes/origin/$main || exit -1
	    # "Already up-to-date." or a list of updates
	    # git gc --prune=now || exit -1

      # check each local branch
      if [ -n "$3" ]; then
        for branch in $(git for-each-ref --format='%(refname)' refs/heads/); do
          name=${branch:11}
          check_remove $name $main
        done
      fi
      if [ -n "$2" ]; then
        check_remove $2 $main
      fi
      if [ -n "$2" ]; then
        git checkout -q $main
        git checkout -q $2
      fi
	else
	    echo "Not a git repsoitory"
	fi
	cd ..
}

for D in *; do
	if [ -d "${D}" ]; then
        update "${D}" $1 $2
    fi
done
echo finished
