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

# This script assumes it is run from the directory holding all github projects in parallel
# bash SupportScripts/setup.sh a_branch_name

do_setup() {
    if [ -d $1 ]; then
        cd $1
        if [ -f setup.py ]; then
            if [ -z "$VIRTUAL_ENV" ] && [ -z "$CONDA_PREFIX" ] && [ -z "$ASROOT" ]; then
                python setup.py develop --user || exit $1
            else
                python setup.py develop || exit $1
            fi
            echo "Finished setup of $1"
        fi
        cd ..
    fi
}

do_setup SpiNNUtils
do_setup SpiNNMachine
do_setup SpiNNMan
do_setup PACMAN
do_setup DataSpecification
do_setup spalloc
do_setup SpiNNFrontEndCommon
do_setup SpiNNakerGraphFrontEnd
do_setup sPyNNaker
do_setup sPyNNaker8
do_setup sPyNNakerVisualisers
do_setup SpiNNGym
