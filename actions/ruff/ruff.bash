#!/bin/bash

# Copyright (c) 2026 The University of Manchester
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

# This bash assumes that other repositories are installed in parallel
# ruffs SpiNNUtils, spinn_machine and unittests

if [ "$#" -eq  "0" ]
  then
    echo "Using previous setup. Provide an argument to run setup"
    source ../../venv/ruff_runner/bin/activate
else
  python3 -m venv ../../venv/ruff_runner
  source ../../venv/ruff_runner/bin/activate
  python3 -m pip install --upgrade ruff
fi

echo ruff statistics
ruff check ../../../SpiNNUtils/spinn_utilities ../../../SpiNNUtils/unittests \
    ../../../SpiNNMachine/spinn_machine ../../../SpiNNMachine/unittests \
    ../../../SpiNNMan/spinnman ../../../SpiNNMan/unittests \
    ../../../SpiNNMan/spinnman_integration_tests ../../../SpiNNMan/manual_scripts \
    ../../../PACMAN/pacman ../../../PACMAN/pacman_test_objects ../../../PACMAN/unittests \
    ../../../spalloc/spalloc_client ../../../spalloc/tests \
    ../../../SpiNNFrontEndCommon/spinn_front_end_common ../../../SpiNNFrontEndCommon/unittests \
    ../../../SpiNNFrontEndCommon/fec_integration_tests \
    ../../../TestBase/spinnaker_testbase ../../../TestBase/unittests \
    ../../../sPyNNaker/spynnaker ../../../sPyNNaker/unittests \
    ../../../sPyNNaker/spynnaker_integration_tests ../../../sPyNNaker/proxy_integration_tests \
    ../../../SpiNNakerGraphFrontEnd/spinnaker_graph_front_end ../../../SpiNNakerGraphFrontEnd/gfe_examples \
    ../../../SpiNNakerGraphFrontEnd/gfe_integration_tests \
    ../../../PyNNExamples/examples ../../../PyNNExamples/balanced_random \
    ../../../PyNNExamples/learning ../../../PyNNExamples/sudoku ../../../PyNNExamples/synfire \
    ../../../sPyNNakerNewModelTemplate/examples ../../../sPyNNakerNewModelTemplate/python_models \
    ../../../sPyNNakerNewModelTemplate/nmt_integration_tests \
    ../../../MarkovChainMonteCarlo/mcmc ../../../MarkovChainMonteCarlo/mcmc_examples \
    ../../../MarkovChainMonteCarlo/mcmc_integration_tests \
    ../../../SpiNNGym/spinn_gym ../../../SpiNNGym/examples ../../../SpiNNGym/integration_tests \
    ../../../BitBrainDemo/bit_brain ../../../BitBrainDemo/unittests \
    --target-version py310 --config ruff_all.toml --statistics
    #../../../sPiNNIRker/spinnirker ../../../sPiNNIRker/unittests ../../../sPiNNIRker/spinnirker_integration_tests \
echo using ruff.toml
ruff check ../../../SpiNNUtils/spinn_utilities ../../../SpiNNUtils/unittests \
    ../../../SpiNNMachine/spinn_machine ../../../SpiNNMachine/unittests \
    ../../../SpiNNMan/spinnman ../../../SpiNNMan/unittests \
    ../../../SpiNNMan/spinnman_integration_tests ../../../SpiNNMan/manual_scripts \
    ../../../PACMAN/pacman ../../../PACMAN/pacman_test_objects ../../../PACMAN/unittests \
    ../../../spalloc/spalloc_client ../../../spalloc/tests \
    ../../../SpiNNFrontEndCommon/spinn_front_end_common ../../../SpiNNFrontEndCommon/unittests \
    ../../../SpiNNFrontEndCommon/fec_integration_tests \
    ../../../TestBase/spinnaker_testbase ../../../TestBase/unittests \
    ../../../sPyNNaker/spynnaker ../../../sPyNNaker/unittests \
    ../../../sPyNNaker/spynnaker_integration_tests ../../../sPyNNaker/proxy_integration_tests \
    ../../../SpiNNakerGraphFrontEnd/spinnaker_graph_front_end ../../../SpiNNakerGraphFrontEnd/gfe_examples \
    ../../../SpiNNakerGraphFrontEnd/gfe_integration_tests \
    ../../../PyNNExamples/examples ../../../PyNNExamples/balanced_random \
    ../../../PyNNExamples/learning ../../../PyNNExamples/sudoku ../../../PyNNExamples/synfire \
    ../../../sPyNNakerNewModelTemplate/examples ../../../sPyNNakerNewModelTemplate/python_models \
    ../../../sPyNNakerNewModelTemplate/nmt_integration_tests \
    ../../../MarkovChainMonteCarlo/mcmc ../../../MarkovChainMonteCarlo/mcmc_examples \
    ../../../MarkovChainMonteCarlo/mcmc_integration_tests \
    ../../../SpiNNGym/spinn_gym ../../../SpiNNGym/examples ../../../SpiNNGym/integration_tests \
    ../../../BitBrainDemo/bit_brain ../../../BitBrainDemo/unittests \
    --target-version py310 --config ruff.toml
echo using ruff_up.toml
ruff check ../../../SpiNNUtils/spinn_utilities ../../../SpiNNUtils/unittests \
    ../../../SpiNNMachine/spinn_machine ../../../SpiNNMachine/unittests \
    ../../../SpiNNMan/spinnman ../../../SpiNNMan/unittests \
    ../../../SpiNNMan/spinnman_integration_tests ../../../SpiNNMan/manual_scripts \
    ../../../PACMAN/pacman ../../../PACMAN/pacman_test_objects ../../../PACMAN/unittests \
    ../../../spalloc/spalloc_client ../../../spalloc/tests \
    ../../../SpiNNFrontEndCommon/spinn_front_end_common ../../../SpiNNFrontEndCommon/unittests \
    ../../../SpiNNFrontEndCommon/fec_integration_tests \
    ../../../TestBase/spinnaker_testbase ../../../TestBase/unittests \
    ../../../sPyNNaker/spynnaker ../../../sPyNNaker/unittests \
    ../../../sPyNNaker/spynnaker_integration_tests ../../../sPyNNaker/proxy_integration_tests \
    ../../../SpiNNakerGraphFrontEnd/spinnaker_graph_front_end ../../../SpiNNakerGraphFrontEnd/gfe_examples \
    ../../../SpiNNakerGraphFrontEnd/gfe_integration_tests \
    ../../../PyNNExamples/examples ../../../PyNNExamples/balanced_random \
    ../../../PyNNExamples/learning ../../../PyNNExamples/sudoku ../../../PyNNExamples/synfire \
    ../../../sPyNNakerNewModelTemplate/examples ../../../sPyNNakerNewModelTemplate/python_models \
    ../../../sPyNNakerNewModelTemplate/nmt_integration_tests \
    ../../../MarkovChainMonteCarlo/mcmc ../../../MarkovChainMonteCarlo/mcmc_examples \
    ../../../MarkovChainMonteCarlo/mcmc_integration_tests \
    ../../../SpiNNGym/spinn_gym ../../../SpiNNGym/examples ../../../SpiNNGym/integration_tests \
    ../../../BitBrainDemo/bit_brain ../../../BitBrainDemo/unittests \
    --target-version py310 --config ruff_up.toml