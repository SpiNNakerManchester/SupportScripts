# Copyright (c) 2018 The University of Manchester
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

import fcntl
from os import O_NONBLOCK as NONBLOCK
from sys import stdout, stderr


def get_flags(channel):
    return fcntl.fcntl(channel, fcntl.F_GETFL)


def set_flags(channel, flags):
    fcntl.fcntl(channel, fcntl.F_SETFL, flags)


flags = get_flags(stdout)
if flags & NONBLOCK:
    set_flags(stdout, flags & ~NONBLOCK)
    stderr.writelines(["Reset STDOUT to blocking"])

flags = get_flags(stderr)
if flags & NONBLOCK:
    set_flags(stderr, flags & ~NONBLOCK)
    stderr.writelines(["Reset STDERR to blocking"])
