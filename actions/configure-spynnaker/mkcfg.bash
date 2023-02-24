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

cfg=~/.spynnaker.cfg

echo '[Machine]' > $cfg

if [ "x$M_ADDR}" = "x" ]; then
	echo "machineName = None" >> $cfg
	echo "version = None" >> $cfg

	echo "spalloc_server = $S_HOST" >> $cfg
	echo "spalloc_port = $S_PORT" >> $cfg
	echo "spalloc_user = $S_USER" >> $cfg
else
	echo "machineName = $M_ADDR" >> $cfg
	echo "version = $M_VERSION" >> $cfg
fi

if [ "x$V_TYPE" = "xtrue" ]; then
	echo "virtual_board = True" >> $cfg
	echo "width = $V_WIDTH" >> $cfg
	echo "height = $V_HEIGHT" >> $cfg
else
	echo "virtual_board = False" >> $cfg
	echo "width = None" >> $cfg
	echo "height = None" >> $cfg
fi

echo "time_scale_factor = $M_TSF" >> $cfg

echo '[Database]' >> $cfg

echo '[Simulation]' >> $cfg

echo '[Buffers]' >> $cfg

echo '[Mode]' >> $cfg
echo "mode = $M_MODE" >> $cfg

echo '[Reports]' >> $cfg
echo "default_report_file_path = $F_PATH" >> $cfg
echo "default_application_data_file_path = $F_PATH" >> $cfg
