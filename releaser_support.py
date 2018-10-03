import os

# modules
import spinn_utilities
import spinnman
import spinnaker_graph_front_end
import spynnaker8
import spynnaker7
import spynnaker
import spinn_front_end_common
import spinn_storage_handlers
import spinn_machine
import nengo_spinnaker_gfe
import python_models8
import spalloc
import spalloc_server
import pacman
import data_specification


from spinn_utilities.citation.tool_citation_generation import CITATION_FILE, \
    CitationAggregator
from spinn_utilities.citation.tool_citation_generation import \
    CitationUpdaterAndDoiGenerator

SPINN_COMMON_PATH = "/c/Users/alan/Documents/software/spinn_common"


class ReleaserSupport(object):

    def __init__(self):
        self._modules_to_release = dict()

        self._update_modules_to_release()
        self._update_modules_for_updating_version_number()

        for module in self._modules_to_release:
            if module["major"] or module["minor"] or module["patch"]:
                VersionUpdator()
                CitationUpdaterAndDoiGenerator()


    def _update_modules_for_updating_version_number(self):
        self._modules_to_release[spinn_utilities]["major"] = False
        self._modules_to_release[spinn_utilities]["minor"] = False
        self._modules_to_release[spinn_utilities]["patch"] = False

        self._modules_to_release[spinnman]["major"] = False
        self._modules_to_release[spinnman]["minor"] = False
        self._modules_to_release[spinnman]["patch"] = False

        self._modules_to_release[spinnaker_graph_front_end]["major"] = False
        self._modules_to_release[spinnaker_graph_front_end]["minor"] = False
        self._modules_to_release[spinnaker_graph_front_end]["patch"] = False

        self._modules_to_release[spynnaker8]["major"] = False
        self._modules_to_release[spynnaker8]["minor"] = False
        self._modules_to_release[spynnaker8]["patch"] = False

        self._modules_to_release[spynnaker7]["major"] = False
        self._modules_to_release[spynnaker7]["minor"] = False
        self._modules_to_release[spynnaker7]["patch"] = False

        self._modules_to_release[spynnaker]["major"] = False
        self._modules_to_release[spynnaker]["minor"] = False
        self._modules_to_release[spynnaker]["patch"] = False

        self._modules_to_release[spinn_front_end_common]["major"] = False
        self._modules_to_release[spinn_front_end_common]["minor"] = False
        self._modules_to_release[spinn_front_end_common]["patch"] = False

        self._modules_to_release[spinn_storage_handlers]["major"] = False
        self._modules_to_release[spinn_storage_handlers]["minor"] = False
        self._modules_to_release[spinn_storage_handlers]["patch"] = False

        self._modules_to_release[spinn_machine]["major"] = False
        self._modules_to_release[spinn_machine]["minor"] = False
        self._modules_to_release[spinn_machine]["patch"] = False

        self._modules_to_release[nengo_spinnaker_gfe]["major"] = False
        self._modules_to_release[nengo_spinnaker_gfe]["minor"] = False
        self._modules_to_release[nengo_spinnaker_gfe]["patch"] = False

        self._modules_to_release[python_models8]["major"] = False
        self._modules_to_release[python_models8]["minor"] = False
        self._modules_to_release[python_models8]["patch"] = False

        self._modules_to_release[spalloc]["major"] = False
        self._modules_to_release[spalloc]["minor"] = False
        self._modules_to_release[spalloc]["patch"] = False

        self._modules_to_release[spalloc_server]["major"] = False
        self._modules_to_release[spalloc_server]["minor"] = False
        self._modules_to_release[spalloc_server]["patch"] = False

        self._modules_to_release[pacman]["major"] = False
        self._modules_to_release[pacman]["minor"] = False
        self._modules_to_release[pacman]["patch"] = False

        self._modules_to_release[data_specification]["major"] = False
        self._modules_to_release[data_specification]["minor"] = False
        self._modules_to_release[data_specification]["patch"] = False

        self._modules_to_release["spinnaker_tools"]["major"] = False
        self._modules_to_release["spinnaker_tools"]["minor"] = False
        self._modules_to_release["spinnaker_tools"]["patch"] = False

        self._modules_to_release["spinn_common"]["major"] = False
        self._modules_to_release["spinn_common"]["minor"] = False
        self._modules_to_release["spinn_common"]["patch"] = False

    def _update_modules_to_release(self):
        python_modules = [
            spinn_utilities, spinnman, spinnaker_graph_front_end,
            spynnaker8, spynnaker7, spynnaker, spinn_front_end_common,
            spinn_storage_handlers, spinn_machine,
            nengo_spinnaker_gfe, python_models8, spalloc,
            spalloc_server, pacman, data_specification]
        for python_module in python_modules:
            self._modules_to_release[python_module] = {
                'module_path': os.path.dirname(os.path.abspath(
                    spinn_utilities.__file__)),
                'citation_file_path': os.path.join(os.path.dirname(
                    os.path.abspath(python_module.__file__)), CITATION_FILE)}

        self._modules_to_release["spinnaker_tools"] = {
            'module_path':
                CitationAggregator.locate_path_for_c_dependency(
                    "spinnaker_tools"),
            'citation_file_path': os.path.join(
                self._modules_to_release["spinnaker_tools"]['module_path'],
                CITATION_FILE)}
        self._modules_to_release["spinn_common"] = {
            'module_path': SPINN_COMMON_PATH,
            'citation_file_path': os.path.join(
                SPINN_COMMON_PATH, CITATION_FILE)}
