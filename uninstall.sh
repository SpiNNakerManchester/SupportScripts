# Copyright (c) 2020 The University of Manchester
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

# This script assumes it is run from the directory holding all github projects in parallel
# bash SupportScripts/uninstall.sh

do_uninstall() {
    if [ -d $1 ]; then
        cd $1
        EXTRA=
        if [ -z "$VIRTUAL_ENV" ] && [ -z "$CONDA_PREFIX" ] && [ -z "$ASROOT" ]; then
            EXTRA=--user
        fi
        pip uninstall -y $EXTRA $2
        python setup.py develop --uninstall $EXTRA
        cd ..
        echo "Uninstalled $1"
    fi
}

do_uninstall SpiNNUtils SpiNNUtilities
do_uninstall SpiNNMachine SpiNNMachine
do_uninstall SpiNNMan SpiNNMan
do_uninstall PACMAN SpiNNaker_PACMAN
do_uninstall spalloc spalloc
do_uninstall SpiNNFrontEndCommon SpiNNFrontEndCommon
do_uninstall SpiNNakerGraphFrontEnd SpiNNakerGraphFrontEnd
do_uninstall sPyNNaker sPyNNaker
do_uninstall sPyNNaker8 sPyNNaker8
do_uninstall sPyNNakerVisualisers sPyNNakerVisualisers
