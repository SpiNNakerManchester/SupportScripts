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

population_count = 0
projection_count = 0
is_setup = False
print_status_messages = True


class Population(object):

    def __init__(self):
        global population_count
        if not is_setup:
            raise NotImplementedError("not setup")
        population_count += 1
        self.id = population_count
        if print_status_messages:
            print("created ", self)

    def __str__(self):
        return "Population:{}".format(self.id)


class Projection(object):
    def __init__(self):
        global projection_count
        if not is_setup:
            raise NotImplementedError("not setup")
        projection_count += 1
        self.id = projection_count
        if print_status_messages:
            print("created ", self)

    def __str__(self):
        return "Projection:{}".format(self.id)


def setup():
    global population_count, projection_count, is_setup
    if is_setup:
        raise NotImplementedError("already setup")
    population_count = 0
    projection_count = 0
    is_setup = True
    if print_status_messages:
        print("setup successful")


def population():
    return Population()


def projection():
    return Projection()


def run():
    if not is_setup:
        raise NotImplementedError("not setup")
    if print_status_messages:
        print("population:", population_count, " projection", projection_count)


def end():
    global is_setup
    if not is_setup:
        raise NotImplementedError("not setup")
    is_setup = False
    if print_status_messages:
        print("end successful")
