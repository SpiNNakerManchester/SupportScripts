# This script assumes it is run from the directory holding all github projects in parallel
# sh SupportScripts/automatic_make.sh

set -e

# Set up the base compilation environment
cd spinnaker_tools
source setup
cd ..

make -C spinnaker_tools clean all
make -C spinn_common clean all install
make -C SpiNNFrontEndCommon/c_common/front_end_common_lib install-clean
make -C SpiNNFrontEndCommon/c_common clean all install

# Set up the neural compilation environment
cd sPyNNaker/neural_modelling
source setup
cd ../..

make -C sPyNNaker/neural_modelling clean all
make -C SpiNNakerGraphFrontEnd/spinnaker_graph_front_end/examples clean all

echo "completed spinnaker binary compilation"
