# Copyright (c) 2023 The University of Manchester
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
# It assume build has been called in all directories.
# It assume that no dist dir holds any code already uploaded to pypi
# bash SupportScripts/pypi.sh

# It is highly recommended you first load to testpypi and test that!

do_twine() {
  cd $1
  twine upload dist/*
  cd ..
}

do_twine SpiNNUtils
do_twine SpiNNMachine
do_twine SpiNNMan
do_twine PACMAN
do_twine spalloc
do_twine SpiNNFrontEndCommon
do_twine TestBase
do_twine SpiNNakerGraphFrontEnd
do_twine sPyNNaker
do_twine sPyNNakerVisualisers
