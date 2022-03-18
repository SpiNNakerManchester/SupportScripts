#!/bin/bash
# This script assumes it is run from the directory holding all github projects in parellel
# sh SupportScripts/gitcheckout.sh a_branch_name


update() {
    cd $1 || return
    if [ -d .git ]; then
        git fetch
        git checkout -q $2 || git checkout -q master || git checkout -q main 2>/dev/null
        branch = $(git rev-parse --abbrev-ref HEAD)
        echo $1 $branch
    fi
    cd ..
}

for D in *; do
    if [ -d "${D}" ]; then
        update "${D}" $1
    fi
done
