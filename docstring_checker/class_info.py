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

all_classes_dict = dict()

STATELESS_MODULES = frozenset(['', 'Enum', 'object', 'property', 'type'])
THREAD_MODULES = frozenset(['Thread'])
EXCEPTION_MODULES = frozenset([
    'Exception', 'KeyError', 'TypeError', 'ValueError'])

# State Levels
MARKER = 0
STATELESS = MARKER + 1
NORMAL = STATELESS + 1
SLOTLESS = NORMAL + 1
THREAD = SLOTLESS + 1
EXCEPTION = THREAD + 1
SLOTS_IMPOSSIBLE = EXCEPTION + 1

STATE_NAMES = {MARKER: "Marker", STATELESS: "Stateless", NORMAL: "Normal",
               SLOTLESS: "Slotless", THREAD: "Thread", EXCEPTION: "Exception",
               SLOTS_IMPOSSIBLE: "Slots impossible"}


class ClassInfo(object):

    __slots__ = ("_file_info", "_line", "_methods", "_name",
                 "_slots", "_slots_impossible", "_state", "_supers", "_users")

    @staticmethod
    def info_by_name(name, file_info=None, line=None):
        if name in all_classes_dict:
            info = all_classes_dict[name]
        else:
            info = ClassInfo(name)
        if file_info is not None:
            info._file_info = file_info
        if line is not None:
            info._line = str(line)
            all_classes_dict[name] = info
        return info

    @staticmethod
    def all_classes():
        return all_classes_dict.values()

    def __init__(self, class_name):
        """
        :param class_name:
        """
        self._name = class_name
        self._slots = None
        self._methods = []
        self._supers = set()
        self._users = set()
        self._state = None
        self._file_info = None
        self._line = None
        all_classes_dict[class_name] = self

    def add_method(self, method):
        self._methods.append(method)

    def add_super_by_name(self, name):
        if name in EXCEPTION_MODULES:
            self._state = EXCEPTION
        elif name in THREAD_MODULES:
            self._state = THREAD
        elif name in STATELESS_MODULES:
            pass
        else:
            super = self.info_by_name(name)
            super._users.add(self)
            self._supers.add(super)

    def gv_name(self):
        if self._name in ["Graph"]:
            return "\"" + self._name + "\""
        return self._name

    def add_graph_lines(self, file, n_count):
        for super in self._supers:
            if super.state == MARKER:
                n_count += 1
                file.write("\t {} -> n{}\n".format(
                    self.gv_name(), n_count))
                file.write("\t n{} [label=\"{}\" color=green]".format(
                    n_count, super.gv_name()))
            elif super.state == STATELESS:
                n_count += 1
                file.write("\t {} -> n{}\n".format(self.gv_name(), n_count))
                file.write(
                    "\t n{} [label=\"{}\" color=yellow]"
                    "".format(n_count, super.gv_name()))
            else:
                file.write("\t {} -> {}\n".format(
                    self.gv_name(), super.gv_name()))
        return n_count

    def location(self):
        if self._file_info is None or self._line is None:
            return "Unknown Location " + self.name
        return "{}:{}".format(self._file_info.path, self._line)

    @property
    def state(self):
        if self._state is None:
            if len(self._methods) == 0:
                self._state = MARKER
            else:
                self._state = STATELESS
            if self._slots == SLOTS_IMPOSSIBLE:
                self._state = SLOTS_IMPOSSIBLE
            elif self._slots is None:
                self._state = max(self._state, SLOTLESS)
            elif len(self._slots) > 0:
                self._state = max(self._state, NORMAL)
            for super in self._supers:
                self._state = max(self._state, super.state)
        return self._state

    @property
    def state_name(self):
        return STATE_NAMES[self.state]

    @property
    def name(self):
        return self._name

    @property
    def slots(self):
        return self._slots

    @slots.setter
    def slots(self, slots):
        self._slots = slots

    @property
    def slots_impossible(self):
        return self._slots_impossible

    @slots.setter
    def slots(self, slots_impossible):
        self._slots = slots_impossible

    @property
    def methods(self):
        return self._methods

    @property
    def supers(self):
        return self._supers

    @property
    def users(self):
        return self._users

    def __str__(self):
        return self._name
