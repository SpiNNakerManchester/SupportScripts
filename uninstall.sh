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
