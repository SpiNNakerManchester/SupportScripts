import yaml
import io
import requests
import shutil

CITATION_FILE_VERSION_FIELD = "version"
CITATION_FILE_DATE_FIELD = "date-released"
CITATION_AUTHORS_TYPE = "authors"
CITATION_AUTHOR_FIRST_NAME = "given-names"
CITATION_AUTHOR_SURNAME = "family-names"
CITATION_FILE_DESCRIPTION = "title"

ZENODO_DEPOSIT_GET_URL = "https://zenodo.org/api/deposit/depositions"
ZENODO_DEPOSIT_PUT_URL = 'https://zenodo.org/api/deposit/depositions/{}/files'
ZENODO_PUBLISH_URL = \
    'https://zenodo.org/api/deposit/depositions/{}/actions/publish'

ZENODO_RELATION_FIELD = "relation"
ZENODO_NEWER_VERSION_OF = 'isNewVersionOf'
ZENODO_SIBLING_OF = "cites"
ZENODO_ACCESS_TOKEN = 'access_token'
ZENODO_RELATED_IDENTIFIERS = 'related_identifiers'
ZENODO_CONTENT_TYPE = "Content-Type"
ZENODO_METADATA = 'metadata'
ZENODO_PRE_RESERVED_DOI = "prereserve_doi"
ZENODO_DOI_VALUE = "doi"
ZENODO_DEPOSIT_ID = 'id'
ZENODO_METADATA_TITLE = "title"
ZENODO_METATDATA_DESC = "description"
ZENODO_METADATA_CREATORS = "creators"
ZENODO_FILE = "file"
ZENODO_AUTHOR_NAME = "name"

AUTHOR_AFFILIATION = "affiliation"
AUTHOR_ORCID = "orcid"
IDENTIFIER = 'identifier'

ZENODO_VALID_STATUS_CODE_REQUEST_GET = 200
ZENODO_VALID_STATUS_CODE_REQUEST_POST = 201
ZENODO_VALID_STATUS_CODE_REQUEST_PUBLISH = 202


class CitationUpdaterAndDoiGenerator(object):

    def __init__(self):
        pass

    def update_citation_file_and_create_doi(
            self, citation_file_path, version_number, version_month,
            version_year,
            version_day, doi_title, create_doi, publish_doi,
            previous_doi, is_previous_doi_sibling, zenodo_access_token,
            module_path):
        """ takes a CITATION.cff file and updates the version and \
        date-released fields, and rewrites the CITATION.cff file.

        :param citation_file_path: The file path to the CITATION.cff file
        :param version_number: the version number to update the citation file \
        version field with
        :type version_number: str
        :param version_month: the version month to update the citation file \
        date-released field with.
        :type version_month: str or int
        :param version_year: the version year to update the citation file \
        date-released field with.
        :type version_year: int
        :param version_day: the version day to update the citation file \
        date-released field with.
        :type version_day: int
        :param create_doi: bool flag for using zenodo doi interface to grab a \
        doi
        :type create_doi: bool
        :param zenodo_access_token: the access token for zenodo
        :type zenodo_access_token: str
        :param publish_doi: bool flag to publish the doi on zenodo
        :type publish_doi: bool
        :param previous_doi: the doi previous to this
        :type previous_doi: str
        :param is_previous_doi_sibling: bool saying if its a sibling or newer \
        version
        :type is_previous_doi_sibling: bool
        :param doi_title: the title for this doi
        :type doi_title: str
        :param module_path: path to the module to zip up
        :type module_path: str
        :rtype: None
        """

        # data holders
        yaml_file = None
        deposit_id = None

        # read in yaml file
        with open(citation_file_path, 'r') as stream:
            try:
                yaml_file = yaml.safe_load(stream)
            except yaml.YAMLError as exc:
                print(exc)

        # update the version number and date-released fields
        yaml_file[CITATION_FILE_VERSION_FIELD] = version_number
        yaml_file[CITATION_FILE_DATE_FIELD] = self.convert_text_date_to_date(
            version_month, version_year, version_day)

        # if creating a doi, go and request one
        if create_doi:
            doi_id, deposit_id = self._request_doi(
                zenodo_access_token, previous_doi, is_previous_doi_sibling)
            yaml_file[IDENTIFIER] = doi_id

        # rewrite citation file with updated fields
        with io.open(citation_file_path, 'w', encoding='utf8') as outfile:
            yaml.dump(yaml_file, outfile, default_flow_style=False,
                      allow_unicode=True)

        # if creating a doi, finish the request and possibly publish it
        if create_doi:
            self._finish_doi(
                deposit_id, zenodo_access_token, publish_doi, doi_title,
                yaml_file[CITATION_FILE_DESCRIPTION], yaml_file, module_path)

    @staticmethod
    def _request_doi(
            zenodo_access_token, previous_doi, is_previous_doi_sibling):
        """ goes to zenodo and requests a doi

        :param zenodo_access_token: zenodo access token
        :type zenodo_access_token: str
        :param previous_doi: the previous doi for this module, if exists
        :type previous_doi: str
        :param is_previous_doi_sibling: bool saying if this module is a \
        sibling or newer version of the previous doi
        :type is_previous_doi_sibling: bool
        :return: the DOI id, and deposit id
        :rtype: str, str
        """

        # create link to previous version (if applicable)
        related = list()
        if previous_doi is not None:
            if is_previous_doi_sibling:
                related.append({
                    ZENODO_RELATION_FIELD: ZENODO_SIBLING_OF,
                    IDENTIFIER: previous_doi})
            else:
                related.append({
                    ZENODO_RELATION_FIELD: ZENODO_NEWER_VERSION_OF,
                    IDENTIFIER: previous_doi})

        # get a request for a doi
        request = requests.get(
            ZENODO_DEPOSIT_GET_URL,
            params={ZENODO_ACCESS_TOKEN: zenodo_access_token,
                    ZENODO_RELATED_IDENTIFIERS: related},
            json={}, headers={ZENODO_CONTENT_TYPE: "application/json"})

        # verify the doi is valid
        if request.status_code != ZENODO_VALID_STATUS_CODE_REQUEST_GET:
            raise Exception(
                "don't know what went wrong. got wrong status code when "
                "trying to request a doi")

        # get doi and deposit id
        doi_id = (request.json()[ZENODO_METADATA][ZENODO_PRE_RESERVED_DOI][
                      ZENODO_DOI_VALUE])
        deposition_id = request.json()[ZENODO_DEPOSIT_ID]

        return doi_id, deposition_id

    def _finish_doi(
            self, deposit_id, access_token, publish_doi, title,
            doi_description, yaml_file, module_path):
        """ publishes the doi to zenodo

        :param deposit_id: the deposit id to publish
        :param access_token: the access token needed to publish
        :param title: the title of this doi
        :param doi_description: the description for the DOI
        :param yaml_file: the citation file after its been read it
        :param publish_doi: bool flagging if we should publish the doi
        :param module_path: the path to the module to doi
        :rtype: None
        """

        data = self._fill_in_data(title, doi_description, yaml_file)
        files = {ZENODO_FILE: self._zip_up_module(module_path)}

        r = requests.post(
            ZENODO_DEPOSIT_PUT_URL.format(deposit_id),
            params={ZENODO_ACCESS_TOKEN: access_token}, data=data, files=files)

        if r.status_code != ZENODO_VALID_STATUS_CODE_REQUEST_POST:
            raise Exception(
                "don't know what went wrong. got wrong status code when "
                "trying to put files and data into the pre allocated doi")

        # publish doi
        if publish_doi:
            request = requests.post(
                ZENODO_PUBLISH_URL.format(deposit_id),
                params={ZENODO_ACCESS_TOKEN: access_token})
            if request.status_code != ZENODO_VALID_STATUS_CODE_REQUEST_PUBLISH:
                raise Exception(
                    "don't know what went wrong. got wrong status code when "
                    "trying to publish the doi")

    @staticmethod
    def _zip_up_module(module_path):
        """ zips up a module
        :param module_path: the path to the module to zip up
        :return: a opened reader for the zip file generated
        """
        shutil.make_archive('module.zip', 'zip', module_path)
        return open('module.zip', "rb")

    @staticmethod
    def _fill_in_data(doi_title, doi_description, yaml_file):
        """ adds in data to the zenodo metadata

        :param doi_title: the title of the doi
        :type doi_title: str
        :param doi_description: the description of the doi
        :type doi_description: str
        :param yaml_file: the citation file once read into the system
        :type yaml_file: dict
        :return: dict containing zenodo metadata
        :rtype: dict
        """
        data = dict()
        data[ZENODO_METADATA] = dict()

        # add basic meta data
        data[ZENODO_METADATA][ZENODO_METADATA_TITLE] = doi_title
        data[ZENODO_METADATA][ZENODO_METATDATA_DESC] = doi_description
        data[ZENODO_METADATA][ZENODO_METADATA_CREATORS] = list()

        # get author data from the citation file
        for author in yaml_file[CITATION_AUTHORS_TYPE]:
            author_data = dict()
            author_data[ZENODO_AUTHOR_NAME] = (
                author[CITATION_AUTHOR_SURNAME] + ", " +
                author[CITATION_AUTHOR_FIRST_NAME] + ", ")
            author_data[AUTHOR_AFFILIATION] = author[AUTHOR_AFFILIATION]
            author_data[AUTHOR_ORCID] = author[AUTHOR_ORCID]
            data[ZENODO_METADATA][ZENODO_METADATA_CREATORS].append(author_data)
        return data

    @staticmethod
    def convert_text_date_to_date(
            version_month, version_year, version_day):
        """ converts the 3 components of a date into a CFF date

        :param version_month: version month, in text form
        :type version_month: text or int
        :param version_year: version year
        :type version_year: int
        :param version_day: version day of month
        :type version_day: int
        :return: the string repr for the cff file
        """
        return "{}-{}-{}".format(
            version_year,
            CitationUpdaterAndDoiGenerator.convert_month_name_to_number(
                version_month),
            version_day)

    @staticmethod
    def convert_month_name_to_number(version_month):
        """ converts a python month in text form to a number form
        YUCK> there must be a better way than this

        :param version_month: the text form of the month
        :type version_month: string or int
        :return: the month int value
        :rtype: int
        :raises: Exception when the month name is not recognised
        """
        if isinstance(version_month, int):
            return version_month
        elif isinstance(version_month, str):
            lower_version_month = version_month.lower()

            if lower_version_month == "january":
                return 1
            if lower_version_month == "february":
                return 2
            if lower_version_month == "march":
                return 3
            if lower_version_month == "april":
                return 4
            if lower_version_month == "may":
                return 5
            if lower_version_month == "june":
                return 6
            if lower_version_month == "july":
                return 7
            if lower_version_month == "august":
                return 8
            if lower_version_month == "september":
                return 9
            if lower_version_month == "october":
                return 10
            if lower_version_month == "november":
                return 11
            if lower_version_month == "december":
                return 12
            raise Exception("don't recognise the month name")
        else:
            raise Exception("don't know the months data type")
