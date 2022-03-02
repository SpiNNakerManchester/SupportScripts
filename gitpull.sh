#!/bin/bash
# This script assumes it is run from the directory holding all github projects in parellel
# sh SupportScripts/gitpull.sh

update(){
	cd $1 || return
	echo
	pwd
	if [ -d .git ]; then
	    # pull
            git pull
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

