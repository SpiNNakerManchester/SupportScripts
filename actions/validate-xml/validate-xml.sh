#!/bin/sh

# Copyright (c) 2020 The University of Manchester
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

file=$1
xpath="string(//*[local-name()='algorithms']/attribute::*[local-name()='schemaLocation'])"
schema=`xmllint --xpath "$xpath" $file | awk '{print $2}'`

if [ -n "$schema" ]; then
	echo "Validating $file against schema $schema"
	exec xmllint --schema "$schema" --noout "$file"
else
	echo "Checking $file for well-formedness"
	exec xmllint --noout "$file"
fi
