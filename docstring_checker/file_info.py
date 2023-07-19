# Copyright (c) 2017 The University of Manchester
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

class FileInfo(object):

    __slots__ = ("_path", "_classes", "_errors")

    def __init__(self, path):
        self._path = path
        self._errors = []
        self._classes = []

    def add_error(self, error):
        self._errors.append(error)

    def add_class(self, class_info):
        self._classes.append(class_info)

    def print_errors(self):
        for error in self._errors:
            print(error)

    def print_classes(self):
        for class_info in self._classes:
            print(class_info.name)

    # def add_graph_lines(self, file):
    #    for class_info in self._classes:
    #        class_info.add_graph_lines(file, by_supers)

    def add_path_lines(self, file):
        for class_info in self._classes:
            file.write("{},{},{}\n".format(
                class_info.name, self.path, class_info.state_name))

    def has_error(self):
        return len(self._errors) > 0

    @property
    def path(self):
        return self._path

    @property
    def errors(self):
        return self._errors

    @property
    def classes(self):
        return self._classes
