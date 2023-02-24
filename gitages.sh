#!/bin/bash
# Copyright (c) 2019 The University of Manchester
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

# For every committed file in the current git repository, report the filename,
# the hash, and the date of the *first* commit to that file. This isn't
# necessarily the age of the content of the file (due to file renaming) but it
# is the most readily available automatically-derived approximation to it.

for filename in $(git ls-files); do
    hash=$(git rev-list HEAD "$filename" | tail -n 1)
    date=$(git show -s --format="%ci" "$hash" --)
    printf "%-35s %s:\n  %s\n" "$filename" "$hash" "$date"
done
