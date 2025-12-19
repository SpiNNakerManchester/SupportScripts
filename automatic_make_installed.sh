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
        # Make and Install if needed
        if [ "$2" == "install" ]; then
            make -C $1 install || exit $?
        else
            make -C $1 || exit $?
        fi
    fi
}

BASEDIR=$(dirname "$0")
echo "$BASEDIR"
C_INSTALLS=$(realpath $BASEDIR/../c_installs)
echo C_INSTALLS "$C_INSTALLS"

if [ -z ${SPINN_INSTALL_DIR+x} ];
then
  export SPINN_INSTALL_DIR=$C_INSTALLS/spinnaker_tools
  echo "set SPINN_INSTALL_DIR to '$SPINN_INSTALL_DIR'"
else
  echo "SPINN_INSTALL_DIR already '$SPINN_INSTALL_DIR'";
fi

if [ -z ${SPINN_COMMON_INSTALL_DIR+x} ];
then
  export SPINN_COMMON_INSTALL_DIR=$C_INSTALLS/spinn_common
  echo "set SPINN_COMMON_INSTALL_DIR to '$SPINN_COMMON_INSTALL_DIR'"
else
  echo "SPINN_COMMON_INSTALL_DIR already '$SPINN_COMMON_INSTALL_DIR'";
fi

if [ -z ${FEC_INSTALL_DIR+x} ];
then
  export FEC_INSTALL_DIR=$C_INSTALLS/front_end_common_lib
  echo "set FEC_INSTALL_DIR to '$FEC_INSTALL_DIR'"
else
  echo "FEC_INSTALL_DIR already '$FEC_INSTALL_DIR'";
fi

if [ -z ${SPYNNAKER_INSTALL_DIRR+x} ];
then
  export SPYNNAKER_INSTALL_DIR=$C_INSTALLS/neural_modelling
  echo "set SPYNNAKER_INSTALL_DIR to '$SPYNNAKER_INSTALL_DIR'"
else
  echo "SPYNNAKER_INSTALL_DIRR already '$SPINN_COMMON_INSTALL_DIR'";
fi

do_make spinnaker_tools install
do_make spinn_common install
do_make SpiNNFrontEndCommon/c_common install
# These are they typical PyNN ones
do_make sPyNNaker/neural_modelling/ install
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