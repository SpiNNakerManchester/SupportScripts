# Copyright (c) 2018 The University of Manchester
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

REQUIRED_REPOS = spinnaker_tools spinn_common SpiNNFrontEndCommon \
	sPyNNaker sPyNNakerNewModelTemplate #SpiNNakerGraphFrontEnd

all: $(REQUIRED_REPOS)
	$(MAKE) -C spinnaker_tools clean all
	$(MAKE) -C spinn_common clean all install
	$(MAKE) -C SpiNNFrontEndCommon/c_common/front_end_common_lib install-clean
	$(MAKE) -C SpiNNFrontEndCommon/c_common clean all install
	$(MAKE) -C sPyNNaker/neural_modelling clean all
	$(MAKE) -C SpiNNakerGraphFrontEnd/gfe_examples clean all
	$(MAKE) -C sPyNNakerNewModelTemplate/c_models clean all

clean: $(REQUIRED_REPOS)
	$(MAKE) -C spinnaker_tools clean
	$(MAKE) -C spinn_common clean
	$(MAKE) -C SpiNNFrontEndCommon/c_common clean
	$(MAKE) -C sPyNNaker/neural_modelling clean
	$(MAKE) -C SpiNNakerGraphFrontEnd/gfe_examples clean
	$(MAKE) -C sPyNNakerNewModelTemplate/c_models clean all

.PHONY: all clean
