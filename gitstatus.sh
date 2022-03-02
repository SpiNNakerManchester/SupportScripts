#!/bin/bash
# This script assumes it is run from the directory holding all github projects in parellel
# sh SupportScripts/gitupdate.sh a_branch_name
status(){
	cd $1 || return
	if [ -d .git ]; then
	    # echo
	    pwd
	    # print status
	    git status -s -b
	fi
	cd ..
}

for D in *; do
	if [ -d "${D}" ]; then
        status "${D}" $1 
    fi
done

