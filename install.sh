#!/bin/bash

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

yes_to_all=""

check_or_install() {
    if [ -d "$1" ]; then
        # Control will enter here if DIRECTORY exists.
        if [ -d "$1/.git" ]; then
            echo $1 already exists so cannot to install $2 there
            return
        else
            echo Directory $1 exists but does not appear to be connected to git
            echo Unable to install $2 there
            return
        fi
    else
        while true; do
            yn="y"
            echo "$yes_to_all"
            if [ "$yes_to_all" == "" ]; then
                read -p "Do you wish to install $2 to $(pwd)/$1 [y]? " yn
                yn=${yn:-y}
            fi
            case $yn in
                [Yy]* ) echo instaling $2;
                    git clone $2
                    echo installed $2 to $(pwd)/$1;
                    break;;
                [Nn]* ) echo Exiting script please rerun or install manually
                    exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
}

install_pynn(){
    check_or_install sPyNNaker https://github.com/SpiNNakerManchester/sPyNNaker.git
    check_or_install sPyNNakerNewModelTemplate https://github.com/SpiNNakerManchester/sPyNNakerNewModelTemplate.git
    check_or_install PyNNExamples https://github.com/SpiNNakerManchester/PyNNExamples.git
}

install_gfe(){
    check_or_install SpiNNakerGraphFrontEnd https://github.com/SpiNNakerManchester/SpiNNakerGraphFrontEnd.git
}

install_extra(){
    check_or_install IntegrationTests https://github.com/SpiNNakerManchester/IntegrationTests.git
    check_or_install TestBase https://github.com/SpiNNakerManchester/TestBase.git
}

install_docs(){
    check_or_install SpiNNakerManchester.github.io https://github.com/SpiNNakerManchester/SpiNNakerManchester.github.io.git
    check_or_install lab_answers https://github.com/SpiNNakerManchester/lab_answers.git
}

case $1 in
    pynn ) echo "Installing for PyNN";;
    gfe) echo "Installing Graph Front End";;
    man ) echo "Installing special manchester repositories";;
    man_extra ) echo "Installing special manchester repositories including docs";;
    all ) echo "Installing All the main repositories";;
    * ) echo "Please specifiy if you wish to install for pynn, gfe, all, man or man_extra:";
        exit;;
esac

if [ $# -gt 1 ]; then
    if [ "$2" == "-y" ]; then
        echo "Installing without prompt"
        yes_to_all="y"
    fi
fi

check_or_install spinnaker_tools https://github.com/SpiNNakerManchester/spinnaker_tools.git
check_or_install spinn_common https://github.com/SpiNNakerManchester/spinn_common.git
check_or_install SpiNNUtils https://github.com/SpiNNakerManchester/SpiNNUtils.git
check_or_install SpiNNMachine https://github.com/SpiNNakerManchester/SpiNNMachine.git
check_or_install PACMAN https://github.com/SpiNNakerManchester/PACMAN.git
check_or_install SpiNNMan https://github.com/SpiNNakerManchester/SpiNNMan.git
check_or_install SpiNNFrontEndCommon https://github.com/SpiNNakerManchester/SpiNNFrontEndCommon.git
check_or_install sPyNNakerVisualisers https://github.com/SpiNNakerManchester/sPyNNakerVisualisers.git
check_or_install IntroLab https://github.com/SpiNNakerManchester/IntroLab.git
check_or_install spalloc https://github.com/SpiNNakerManchester/spalloc.git
check_or_install JavaSpiNNaker https://github.com/SpiNNakerManchester/JavaSpiNNaker.git

case $1 in
    pynn )
        install_pynn
        ;;
    gfe )
        install_gfe
        ;;
    man )
        install_pynn
        install_gfe
        install_extra
        ;;
    man_extra )
        install_pynn
        install_gfe
        install_extra
        install_docs
        ;;
    all )
        install_pynn
        install_gfe
        ;;
    * ) echo "Shouldn't be possible to get here!";
        exit;;
esac
