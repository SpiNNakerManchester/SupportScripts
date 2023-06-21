#!/bin/bash

release() {
    reponame=$1
    repo=$2
    folder=$3
    if [ -d "$folder" ]; then
        cd $folder
        if [ -f setup.py ]; then
            pkg_name=$(python setup.py --name)
            version=$(python setup.py --version)
            fullname=$(python setup.py --fullname)
            if curl --output /dev/null --silent --head --fail "$repo/project/$pkg_name/$version/"; then
                echo "Skipping $fullname as already uploaded"
            else
                echo "Releasing $fullname"
                output=$(python setup.py sdist upload -r $reponame) || exit $?
            fi
        fi
        cd ..
    fi
}

reponame=$1
repo=$(python -c "import os; import configparser; from urllib.parse import urlparse; config = configparser.ConfigParser(); config.read(os.path.expanduser('~/.pypirc')); bits = urlparse(config['$reponame']['repository']); print('{}://{}/'.format(bits.scheme, bits.netloc))") || exit 1
echo "Uploading to $1 = $repo"

release $reponame $repo SpiNNUtils
release $reponame $repo SpiNNMachine
release $reponame $repo SpiNNMan
release $reponame $repo PACMAN
release $reponame $repo spalloc
release $reponame $repo SpiNNFrontEndCommon
release $reponame $repo SpiNNakerGraphFrontEnd
release $reponame $repo sPyNNaker
release $reponame $repo sPyNNakerVisualisers
