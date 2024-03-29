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

import os
from subprocess import call
from file_doc_checker import FileDocChecker
import class_info as class_info

_EXCLUDES = ["va_benchmark.py"]
_OK_EXCLUDES = ["setup.py"]


def find_groups_up_and_down(info, found):
    if info in found:
        return
    found.add(info)
    for super in info.supers:
        find_groups_up_and_down(super, found)
    if info.state > class_info.STATELESS:
        for user in info.users:
            find_groups_up_and_down(user, found)


def find_groups_up(info, found, base):
    if info in found:
        if base is not None:
            print("Diamond found over: {}".format(base.name))
        return
    found.add(info)
    for user in info.users:
        find_groups_up(user, found, base)


def graph(infos, name):
    gv_name = name + ".gv"
    png_name = name + ".png"
    with open(gv_name, "w") as file:
        n_count = 0
        file.write("digraph G {\n")
        for info in infos:
            n_count = info.add_graph_lines(file, n_count)
        file.write("}")
    call(["dot", "-Tpng", gv_name, "-o", png_name])


def graph_infos_by_group(infos):
    graph_count = 0
    while len(infos) > 0:
        info = infos[0]
        if ((len(info.supers)) == 0 and (len(info.users) == 0)) or \
                (info.state <= class_info.STATELESS):
            infos.remove(info)
        else:
            info_group = set()
            find_groups_up_and_down(info, info_group)
            graph_count += 1
            graph(info_group, "supers/graph{}".format(graph_count))
            for gr_info in info_group:
                if gr_info in infos:
                    infos.remove(gr_info)
#            find_diamond(gr_info)


def graph_by_super(info):
    info_group = set()
    if info.state > class_info.STATELESS:
        base = info
    else:
        base = None
    find_groups_up(info, info_group, base)
    if (len(info_group) >= 2):
        graph(info_group, "supers/" + info.name)


def graph_by_supers(infos):
    for info in infos:
        if len(info.users) > 0:
            graph_by_super(info)


def double_dependency_check(infos, root):
    for info in infos:
        if info.state == class_info.SLOTS_IMPOSSIBLE:
            print("No __slots__ possible:", info)
            # print root + info.location()
        elif len(info.supers) > 1:
            count = 0
            for super in info.supers:
                if super.state > class_info.STATELESS:
                    count += 1
            if count > 1:
                print("DOUBLE!")
                print(root + info.location())
                for super in info.supers:
                    if super.state > class_info.STATELESS:
                        print(root + super.location())
                print


def check_directory(path, pynn_version):
    infos = []
    error = False
    realpath = os.path.realpath(path)
    if os.path.isfile(realpath):
        fileDocChecker = FileDocChecker(realpath)
        info = fileDocChecker.check_all_docs()
        error = error or info.has_error()
        infos.append(info)
    else:
        if pynn_version == 7:
            pynn_ignore = "sPyNNaker8"
        elif pynn_version == 8:
            pynn_ignore = "sPyNNaker7"
        else:
            raise ValueError("Unexpected version")
        for root, dirs, files in os.walk(realpath, topdown=True):
            for name in files:
                if name.endswith(".py"):
                    if name in _EXCLUDES:
                        print("ignoring:", name)
                    elif name in _OK_EXCLUDES:
                        pass
                    else:
                        path = os.path.join(root, name)
                        fileDocChecker = FileDocChecker(path, root=realpath)
                        info = fileDocChecker.check_all_docs()
                        error = error or info.has_error()
                        infos.append(info)
            # Not ready to check
            if ("my_spinnaker") in dirs:
                dirs.remove("my_spinnaker")
            for dir in dirs:
                if pynn_ignore in dir:
                    print("Ignoring:", dir)
                    dirs.remove(dir)
            # differenc docstring style
            if root.endswith("spalloc_server") and "docs" in dirs:
                dirs.remove("docs")
            if "application_generated_data_files" in dirs:
                dirs.remove("application_generated_data_files")
            if "reports" in dirs:
                dirs.remove("reports")
            if ".git" in dirs:
                dirs.remove(".git")
            if "doc" in dirs:
                dirs.remove("doc")
            if ".idea" in dirs:
                dirs.remove(".idea")

    print("Writing csv")
    with open("paths.csv", "w") as file:
        file.write("Class Name,Path\n")
        for info in infos:
            info.add_path_lines(file)
    print("checking double depencies")
    double_dependency_check(class_info.ClassInfo.all_classes(), realpath)
    # print("Writing graphs")
    # graph_infos_by_group(class_info.ClassInfo.all_classes())
    # graph_by_supers(class_info.ClassInfo.all_classes())
    # if error:
    #    print("******* ERRORS FOUND **********")
    #    for info in infos:
    #        info.print_errors()
    #    print("******* ERRORS FOUND **********")
    #    sys.exit(1)


if __name__ == "__main__":
    check_directory("../../", 7)
