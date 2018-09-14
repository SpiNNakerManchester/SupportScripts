import os
import yaml
import io
import importlib
from os import environ

from citation_update import _convert_text_date_to_date

REQUIREMENTS_FILE = "requirements.txt"
CITATION_FILE = "CITATION.cff"
PYPI_TO_IMPORT_FILE = "pypi_to_import"

REFERENCES_YAML_POINTER = "references"
REFERENCE_TYPE = "software"
REFERENCES_AUTHORS_TYPE = "authors"
REFERENCES_TITLE_TYPE = "title"
REFERENCES_VERSION_TYPE = "version"
REFERENCES_DATE_TYPE = "date-released"
REFERENCES_URL_TYPE = "url"
REFERENCES_REPO_TYPE = "repository"
REFERENCES_CONTACT_TYPE = "contact"
REFERENCES_EMAIL_TYPE = "email"
REFERENCES_TYPE_TYPE = "type"
REFERENCES_SOFTWARE_TYPE = "software"

AGGREGATE_FILE_NAME = CITATION_FILE


def create_aggregated_citation_file(
        module_to_start_at, file_path_of_aggregated_citation_file):

    # get the top citation file to add references to
    top_citation_file_path = os.path.join(os.path.dirname(os.path.dirname(
        os.path.abspath(module_to_start_at.__file__))), CITATION_FILE)
    top_citation_file = None
    with open(top_citation_file_path, 'r') as stream:
        try:
            top_citation_file = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)
    top_citation_file[REFERENCES_YAML_POINTER] = list()

    # get the dependency list
    requirements_file_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(
            module_to_start_at.__file__))),
        REQUIREMENTS_FILE)

    # attempt to get python pypi to import command map
    pypi_to_import_map_file = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(
            module_to_start_at.__file__))),
        PYPI_TO_IMPORT_FILE)
    pypi_to_import_map = None
    if os.path.isfile(pypi_to_import_map_file):
        pypi_to_import_map = _read_pypi_import_map(pypi_to_import_map_file)

    if os.path.isfile(requirements_file_path):
        for line in open(requirements_file_path, "r"):
            module_to_get_requirements_for = line.split(" ")[0]
            _handle_dependency(
                top_citation_file, module_to_get_requirements_for,
                pypi_to_import_map)

    # write citation file with updated fields
    aggregated_citation_file = os.path.join(
        file_path_of_aggregated_citation_file, AGGREGATE_FILE_NAME)
    with io.open(aggregated_citation_file, 'w', encoding='utf8') as outfile:
        yaml.dump(top_citation_file, outfile, default_flow_style=False,
                  allow_unicode=True)


def _read_pypi_import_map(aggregated_citation_file):
    pypi_to_import_map = dict()
    for line in open(aggregated_citation_file, "r"):
        [pypi, import_command] = line.split(":")
        pypi_to_import_map[pypi] = import_command.split("\n")[0]
    return pypi_to_import_map


# noinspection PyBroadException
def _handle_dependency(
        top_citation_file, module_to_get_requirements_for,
        pypi_to_import_map):
    """ handles a dependency, assumes its either python or c code 
    
    :param top_citation_file: yaml file for the top citation file
    :param module_to_get_requirements_for: module to import
    :type top_citation_file: yaml file
    :type module_to_get_requirements_for: str
    :param pypi_to_import_map: map between pypi name and the python import
    :type pypi_to_import_map: dict
    :return: None
    """
    # assume its a python import to begin with


    try:
        imported_module = importlib.import_module(
            pypi_to_import_map[module_to_get_requirements_for])
        _handle_python_dependency(top_citation_file, imported_module)
    except Exception as e:
        # assume now that its a c code module.
        _handle_c_dependency(
            top_citation_file, module_to_get_requirements_for)


def _handle_c_dependency(
        top_citation_file, module_to_get_requirements_for):
    """ handles a c code dependency
    
    :param top_citation_file: yaml file for the top citation file
    :param module_to_get_requirements_for: module to import
    :type top_citation_file: yaml file
    :type module_to_get_requirements_for: str
    :return: None
    """
    environment_path_variable = environ.get('PATH')
    if environment_path_variable is not None:
        software_paths = environment_path_variable.split(":")
        for software_path in software_paths:
            if len(software_path.split(module_to_get_requirements_for)) != 1:
                citation_file_path =

    return


def _handle_python_dependency(top_citation_file, imported_module):
    """ handles a python dependency
    
    :param top_citation_file: yaml file for the top citation file
    :type top_citation_file: yaml file
    :param: imported_module: the actual imported module
    :type imported_module: ModuleType
    :return: None
    """
    # get modules citation file
    top_citation_file_path = os.path.join(
        os.path.dirname(os.path.dirname(
            os.path.abspath(imported_module.__file__))), CITATION_FILE)

    # if it exists, add it as a reference to the top one
    if os.path.isfile(top_citation_file_path):
        dependency_citation_file = None
        with open(top_citation_file_path, 'r') as stream:
            try:
                dependency_citation_file = yaml.safe_load(stream)
            except yaml.YAMLError as exc:
                print(exc)

            reference_entry = dict()
            reference_entry[REFERENCES_TYPE_TYPE] = REFERENCES_SOFTWARE_TYPE
            reference_entry[REFERENCES_AUTHORS_TYPE] = \
                dependency_citation_file[REFERENCES_AUTHORS_TYPE]
            reference_entry[REFERENCES_TITLE_TYPE] = \
                dependency_citation_file[REFERENCES_TITLE_TYPE]
            reference_entry[REFERENCES_CONTACT_TYPE] = \
                dependency_citation_file[REFERENCES_CONTACT_TYPE]
            reference_entry[REFERENCES_VERSION_TYPE] = \
                dependency_citation_file[REFERENCES_VERSION_TYPE]
            reference_entry[REFERENCES_DATE_TYPE] = \
                dependency_citation_file[REFERENCES_DATE_TYPE]
            reference_entry[REFERENCES_URL_TYPE] = \
                dependency_citation_file[REFERENCES_URL_TYPE]
            reference_entry[REFERENCES_REPO_TYPE] = \
                dependency_citation_file[REFERENCES_REPO_TYPE]
            reference_entry[REFERENCES_EMAIL_TYPE] = \
                dependency_citation_file[REFERENCES_EMAIL_TYPE]

            # append to the top citation file
            top_citation_file[REFERENCES_YAML_POINTER].append(reference_entry)

    else:  # no citation file exists. build minimal one from version
        try:
            version = imported_module.version
            reference_entry = dict()
            reference_entry[REFERENCES_TYPE_TYPE] = REFERENCES_SOFTWARE_TYPE
            reference_entry[REFERENCES_VERSION_TYPE] = \
                _convert_text_date_to_date(
                    version_day=version.__version_day__,
                    version_month=version.__version_month__,
                    version_year=version.__version_year__)
        except Exception:  # no idea how to deal with it now
            pass

import spinn_utilities
import spynnaker8
create_aggregated_citation_file(
    spynnaker8, os.path.dirname(os.path.abspath(__file__)))