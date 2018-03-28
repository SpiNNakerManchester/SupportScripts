REQUIRED_REPOS = SpiNNFrontEndCommon

all: $(REQUIRED_REPOS)
	$(MAKE) -C SpiNNFrontEndCommon/cpp_common clean install

clean: $(REQUIRED_REPOS)
	$(MAKE) -C SpiNNFrontEndCommon/cpp_common clean

.PHONY: all clean
