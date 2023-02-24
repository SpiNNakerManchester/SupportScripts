#!/bin/bash

# Copyright (c) 2017 The University of Manchester
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# You need to add this to your .travis.yml
#
#  addons:
#    apt:
#      packages:
#        - vera++
#
#  script:
#    - path-to/this-dir/in-repo/run-vera.sh path/to/C-source-tree

vroot=`dirname $0`/vera++
root="$1"
shift
pattern='*.[ch]'
prof="--profile spinnaker.tcl"
if [[ "${@#--profile}" = "$@" ]]; then :; else
	prof=""
fi
find $root -name '*.[ch]' -o -name '*.cpp' | vera++ --root $vroot $prof --error ${1+"$@"}
exit $?
