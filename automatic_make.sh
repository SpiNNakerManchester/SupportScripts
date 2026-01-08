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
        # Clean
        make -C $1 clean || exit $?
        # Clean installation; ignore error if install-clean doesn't work
        # (probably because there is no install clean for most targets)
        #make -C $1 install-clean || true
        # Make
        make -C $1 || exit $?
        # Install if needed
        if [ "$2" == "install" ]; then
            make -C $1 install || exit $?
        fi
    fi
}

if ! [ -z ${SPINN_COMMON_INSTALL_DIR+x} ];
then
  echo As SPINN_COMMON_INSTALL_DIR is set please use automatic_make_installed.sh
  exit 1
fi

do_make spinnaker_tools
do_make spinn_common
do_make SpiNNFrontEndCommon/c_common
# These are they typical PyNN ones
do_make sPyNNaker/neural_modelling/
do_make sPyNNakerNewModelTemplate/c_models/
# These are for users not using PyNN
do_make SpiNNakerGraphFrontEnd/gfe_examples/
do_make SpiNNakerGraphFrontEnd/gfe_integration_tests/
# These are unlikely to be used outside of Manchester University
do_make SpiNNGym/c_code
do_make SpiNNaker_PDP2/c_code
do_make MarkovChainMonteCarlo/c_models
do_make TSPonSpiNNaker/spinnaker_c
do_make BitBrainDemo/bit_brain_host_c
do_make BitBrainDemo/bit_brain_spinnaker_c

python -m spinn_utilities.make_tools.check_database_keys
