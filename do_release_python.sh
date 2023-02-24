# Copyright (c) 2021 The University of Manchester
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
release $reponame $repo DataSpecification
release $reponame $repo spalloc
release $reponame $repo SpiNNFrontEndCommon
release $reponame $repo SpiNNakerGraphFrontEnd
release $reponame $repo sPyNNaker
release $reponame $repo sPyNNakerVisualisers
