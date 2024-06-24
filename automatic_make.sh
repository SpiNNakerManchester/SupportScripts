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

# This script assumes it is run from the directory holding all github projects in parallel
# bash SupportScripts/automatic_make.sh

do_make() {
    if [ -d "$1" ]; then
        # Control will enter here if DIRECTORY exists.
        # Run setup.bash if it exists
        if [ -f "$1/setup.bash" ]; then
            cd $1
            source setup.bash || exit $?
            cd -
        fi
        if [ -f "$1/setup" ]; then
            cd $1
            source setup || exit $?
            cd -
        fi
        # Clean
        make -C $1 clean || exit $?
        # Clean installation; ignore error if install-clean doesn't work
        # (probably because there is no install clean for most targets)
        make -C $1 install-clean || true
        # Make
        make -C $1 || exit $?
        # Install if needed
        if [ "$2" == "install" ]; then
            make -C $1 install || exit $?
        fi
    fi
}

do_make spinnaker_tools
do_make spinn_common install
do_make SpiNNFrontEndCommon/c_common/front_end_common_lib install
do_make SpiNNFrontEndCommon/c_common/ install
do_make sPyNNaker/neural_modelling/
do_make sPyNNakerNewModelTemplate/c_models/
do_make SpiNNakerGraphFrontEnd/gfe_examples/
do_make SpiNNakerGraphFrontEnd/gfe_integration_tests/
do_make SpiNNGym/c_code
do_make SpiNNaker_PDP2/c_code
do_make MarkovChainMonteCarlo/c_models
do_make TSPonSpiNNaker/spinnaker_c