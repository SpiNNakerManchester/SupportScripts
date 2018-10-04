import os
from _ordereddict import ordereddict

import spinn_utilities
import spinnman
from spinn_front_end_common.utilities import globals_variables
import spinnaker_graph_front_end._version as gfe_version
globals_variables.unset_simulator()
globals_variables._failed_state = None
import spynnaker8._version as pynn8_version
import spynnaker7._version as pynn7_version
import spynnaker._version as spynnaker_version
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
from version_updater import update_version_file, LANGUAGE_CODES

# FIX THIS
SPINN_COMMON_PATH = "C:\Users\\alan\Documents\software\spinn_common"

# UPDATE THIS
NEW_VERSION_NAME = "Determinist"

# SWITCH THIS WHEN READY
PUBLISH_DOI = False

# INSERT YOUR OWN ZENODO ACCESS TOKEN HERE, got from
# https://zenodo.org/account/settings/applications/tokens/new/
ZENODO_ACCESS_TOKEN = ""

# UPDATE THIS FOR SECOND USAGE
PREVIOUS_DOIS = {
    pynn8_version: "https://zenodo.org/record/1255864#.W7YHW2hKiUk",
    pynn7_version: "https://zenodo.org/record/1255864#.W7YHW2hKiUk"
}

# UPDATE IF NEW MODULES EXIST
doi_title = {
    spinn_utilities: "SpiNNaker Utilities",
    spinnman: "Python Host to SpiNNaker Machines interface",
    gfe_version: "Python Host top level API for SpiNNaker toolchain",
    pynn8_version: "PyNN (0.8/0.9) on SpiNNaker API",
    pynn7_version: "PyNN (0.75) on SpiNNaker API",
    spynnaker_version: "Common functionality for PyNN on SpiNNaker API",
    spinn_front_end_common: "Common functionality for SpiNNaker Front Ends",
    spinn_storage_handlers: "General SpiNNaker File writers / readers",
    spinn_machine: "Pythonic representation of a SpiNNaker Machine",
    nengo_spinnaker_gfe: " Nengo on SpiNNaker API",
    python_models8: "New model template for PyNN (0.8/ 0.9) on SpiNNaker",
    spalloc: "SpiNNaker machine allocation client",
    spalloc_server: "SpiNNaker machine allocation server",
    pacman: "SpiNNaker mapping alogirthms",
    data_specification: "SpiNNaker Data compression Language",
    "spinnaker_tools": "SpiNNaker C code and low level tools",
    "spinn_common": "SpiNNaker C supplemental code"
}

# UPDATE IF NEW MODULES EXIST
PYTHON_MODULES = [
    spinn_utilities,
    spinnman,
    pynn8_version,
    pynn7_version,
    spynnaker_version,
    spinn_front_end_common,
    spinn_storage_handlers,
    spinn_machine,
    nengo_spinnaker_gfe,
    python_models8,
    spalloc,
    spalloc_server,
    pacman,
    data_specification,
    gfe_version]


class ReleaserSupport(object):

    def __init__(self):
        self._modules_to_release = ordereddict()

        self._setup_paths_input_data()
        self._set_up_version_upgrade_points_for_release()

        for release_module in self._modules_to_release:
            print "processing module {}".format(release_module)
            if (not self._modules_to_release[release_module]["major"] or
                    self._modules_to_release[release_module]["minor"] or
                    self._modules_to_release[release_module]["patch"]):
                version_number, version_month, version_year, version_day = \
                    update_version_file(
                        self._modules_to_release[release_module]["language"],
                        self._modules_to_release[release_module]
                        ["version_path"],
                        self._modules_to_release[release_module]["major"],
                        self._modules_to_release[release_module]["minor"],
                        self._modules_to_release[release_module]["patch"],
                        NEW_VERSION_NAME)
                citation_updater = CitationUpdaterAndDoiGenerator()
                citation_updater.update_citation_file_and_create_doi(
                    self._modules_to_release[release_module]
                    ["citation_file_path"],
                    update_version=True,
                    version_number=version_number, version_month=version_month,
                    version_year=version_year, version_day=version_day,
                    doi_title=(self._modules_to_release[release_module]
                               ["doi_title"] + version_number),
                    create_doi=True, publish_doi=PUBLISH_DOI,
                    previous_doi=(
                        self._modules_to_release[release_module]
                        ["previous_doi"]),
                    is_previous_doi_sibling=False,
                    zenodo_access_token=ZENODO_ACCESS_TOKEN,
                    module_path=(
                        self._modules_to_release[release_module]
                        ["module_path"]))
            print "processed module {}".format(release_module)

    def _set_up_version_upgrade_points_for_release(self):
        self._modules_to_release[spinn_utilities]["major"] = False
        self._modules_to_release[spinn_utilities]["minor"] = False
        self._modules_to_release[spinn_utilities]["patch"] = False

        self._modules_to_release[spinnman]["major"] = False
        self._modules_to_release[spinnman]["minor"] = False
        self._modules_to_release[spinnman]["patch"] = False

        self._modules_to_release[gfe_version]["major"] = False
        self._modules_to_release[gfe_version]["minor"] = False
        self._modules_to_release[gfe_version]["patch"] = False

        self._modules_to_release[pynn8_version]["major"] = False
        self._modules_to_release[pynn8_version]["minor"] = False
        self._modules_to_release[pynn8_version]["patch"] = False

        self._modules_to_release[pynn7_version]["major"] = False
        self._modules_to_release[pynn7_version]["minor"] = False
        self._modules_to_release[pynn7_version]["patch"] = False

        self._modules_to_release[spynnaker_version]["major"] = False
        self._modules_to_release[spynnaker_version]["minor"] = False
        self._modules_to_release[spynnaker_version]["patch"] = False

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

    def _setup_paths_input_data(self):
        for python_module in PYTHON_MODULES:
            self._modules_to_release[python_module] = {
                'module_path': os.path.dirname(os.path.dirname(os.path.abspath(
                    python_module.__file__))),
                'version_path': os.path.join(os.path.dirname(os.path.abspath(
                    python_module.__file__)), "_version.py"),
                'citation_file_path': os.path.join(
                    os.path.dirname(os.path.dirname(os.path.abspath(
                        python_module.__file__))), CITATION_FILE),
                'language': LANGUAGE_CODES.PYTHON,
                'doi_title': doi_title[python_module]}
            if python_module in PREVIOUS_DOIS:
                self._modules_to_release[python_module]["previous_doi"] = \
                    PREVIOUS_DOIS[python_module]
            else:
                self._modules_to_release[python_module]["previous_doi"] = None

        self._modules_to_release["spinnaker_tools"] = {
            'module_path':
                CitationAggregator.locate_path_for_c_dependency(
                    "spinnaker_tools"),
            'version_path': os.path.join(
                CitationAggregator.locate_path_for_c_dependency(
                    "spinnaker_tools"),
                "include" + os.sep + "version.h"),
            'citation_file_path': os.path.join(
                CitationAggregator.locate_path_for_c_dependency(
                    "spinnaker_tools"), CITATION_FILE),
            'language': LANGUAGE_CODES.C,
            'doi_title': doi_title["spinnaker_tools"]}
        if "spinnaker_tools" in PREVIOUS_DOIS:
            self._modules_to_release["spinnaker_tools"]["previous_doi"] = \
                PREVIOUS_DOIS["spinnaker_tools"]
        else:
            self._modules_to_release["spinnaker_tools"]["previous_doi"] = None

        self._modules_to_release["spinn_common"] = {
            'module_path': SPINN_COMMON_PATH,
            'citation_file_path': os.path.join(
                SPINN_COMMON_PATH, CITATION_FILE),
            'language': LANGUAGE_CODES.C,
            'version_path': os.path.join(
                CitationAggregator.locate_path_for_c_dependency(
                    "spinnaker_tools"),
                "include" + os.sep + "version.h"),
            'doi_title': doi_title["spinn_common"]}
        if "spinn_common" in PREVIOUS_DOIS:
            self._modules_to_release["spinn_common"]["previous_doi"] = \
                PREVIOUS_DOIS["spinn_common"]
        else:
            self._modules_to_release["spinn_common"]["previous_doi"] = None

x = ReleaserSupport()
