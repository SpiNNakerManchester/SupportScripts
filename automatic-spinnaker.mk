REQUIRED_REPOS = spinnaker_tools spinn_common SpiNNFrontEndCommon \
	sPyNNaker sPyNNaker8NewModelTemplate #SpiNNakerGraphFrontEnd

all: $(REQUIRED_REPOS)
	$(MAKE) -C spinnaker_tools clean all
	$(MAKE) -C spinn_common clean all install
	$(MAKE) -C SpiNNFrontEndCommon/c_common/front_end_common_lib install-clean
	$(MAKE) -C SpiNNFrontEndCommon/c_common clean all install
	$(MAKE) -C sPyNNaker/neural_modelling clean all
	$(MAKE) -C SpiNNakerGraphFrontEnd/spinnaker_graph_front_end/examples clean all
	$(MAKE) -C sPyNNaker8NewModelTemplate/c_models clean all

clean: $(REQUIRED_REPOS)
	$(MAKE) -C spinnaker_tools clean
	$(MAKE) -C spinn_common clean
	$(MAKE) -C SpiNNFrontEndCommon/c_common clean
	$(MAKE) -C sPyNNaker/neural_modelling clean
	$(MAKE) -C SpiNNakerGraphFrontEnd/spinnaker_graph_front_end/examples clean
	$(MAKE) -C sPyNNaker8NewModelTemplate/c_models clean all

.PHONY: all clean

