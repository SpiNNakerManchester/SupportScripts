#!/bin/bash

# Copyright (c) 2019 The University of Manchester
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

dir0=$(dirname $BASH_SOURCE)
op="$1"
shift
ratver=0.13
### SELECT MIRROR!
# apachebase="https://www.mirrorservice.org/sites/ftp.apache.org/"
apachebase="https://mirror.ox.ac.uk/sites/rsync.apache.org/"
raturl="${apachebase}creadur/apache-rat-${ratver}/apache-rat-${ratver}-bin.tar.gz"
ant=${ANT-ant}
case $op in
	download)
		if curl -s -I -D - "$raturl" 2>/dev/null | grep -q 'application/x-gzip'; then
			curl -s --output - "$raturl" | (cd $dir0 && tar -zxf -)
		else
			echo "Version of RAT ($ratver) is wrong?"
			echo "RAT URL: $raturl"
		fi
		;;
	run)
		# java -jar "${dir0}/apache-rat-${ratver}/apache-rat-${ratver}.jar" ${1+"$@"}
		eval $ant "-e -q -f $dir0/rat.xml -lib $dir0/apache-rat-$ratver rat"
		;;
	*)
		echo "unknown op \"$op\": must be download or run" >&2
		exit 1
		;;
esac
exit $?
