#!/bin/bash

# Copyright (c) 2020 The University of Manchester
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

dict=/tmp/dict.txt

set +e

if [ "$RC" = "global_relaxed" ]; then
  RC="$RELAXED_RC"
  echo "Using global relaxed rcfile $RC"
elif [ "$RC" = "global_strict" ]; then
  RC="$STRICT_RC"
  echo "Using global strict rcfile $RC"
else
  echo "Using local rcfile $RC"
fi

if test -n "$SPELL_LANG"; then
	pylint --output-format=colorized "--disable=$DISABLE_CATS" \
		--persistent=no "--jobs=$JOBS" "--rcfile=$RC" \
		"--spelling-dict=$SPELL_LANG" "--spelling-private-dict-file=$dict" \
		$PACKAGES
else
	pylint --output-format=colorized "--disable=$DISABLE_CATS" \
		--persistent=no "--jobs=$JOBS" "--rcfile=$RC" \
		$PACKAGES
fi

# Note that there's special conditioning of the return code of pylint
exit $(( $? & ($FAIL_CODE | 33) ))
# Fatal (1) and Usage (32) errors are ALWAYS enabled in the bit mask
