# This script assumes it is run from the directory holding all github projects in parallel
# sh SupportScripts/automatic_spinnaker_make.sh

set -e
wd=`pwd`

# Set up the base compilation environment
cd spinnaker_tools
source setup
cd ${wd}

# Set up the neural compilation environment
cd sPyNNaker/neural_modelling
source setup
cd ${wd}

make -f SupportScripts/automatic-spinnaker.mk

echo "completed spinnaker binary compilation"
