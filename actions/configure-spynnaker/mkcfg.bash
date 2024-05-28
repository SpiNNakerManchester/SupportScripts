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


echo '[Machine]' > $CFG_FILE

if [ "x$V_TYPE" = "xtrue" ]; then
	echo "virtual_board = True" >> $CFG_FILE
	echo "width = $V_WIDTH" >> $CFG_FILE
	echo "height = $V_HEIGHT" >> $CFG_FILE
elif [ "x$M_ADDR}" = "x" ]; then
	echo "spalloc_server = $S_HOST" >> $CFG_FILE
	echo "spalloc_port = $S_PORT" >> $CFG_FILE
	echo "spalloc_user = $S_USER" >> $CFG_FILE
else
	echo "machineName = $M_ADDR" >> $CFG_FILE
	echo "version = $M_VERSION" >> $CFG_FILE
fi

echo "time_scale_factor = $M_TSF" >> $CFG_FILE

echo '[Database]' >> $CFG_FILE

echo '[Simulation]' >> $CFG_FILE

echo '[Buffers]' >> $CFG_FILE

echo '[Mode]' >> $CFG_FILE
echo "mode = $M_MODE" >> $CFG_FILE

echo '[Reports]' >> $CFG_FILE
echo "default_report_file_path = $F_PATH" >> $CFG_FILE
echo "default_application_data_file_path = $F_PATH" >> $CFG_FILE
