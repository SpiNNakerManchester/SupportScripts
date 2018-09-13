import yaml
import io

CITATION_FILE_VERSION_FIELD = "version"
CITATION_FILE_DATE_FIELD = "date-released"

def update_citation_file(
        citation_file_path, version_number, version_month, version_year,
        version_day):
    """ takes a CITATION.cff file and updates the version and date-released 
    fields, and rewrites the CITATION.cff file.
    
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
    :return: None
    """

    # read in yaml file
    yaml_file = None
    with open(citation_file_path, 'r') as stream:
        try:
             yaml_file = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)

    # update the version number and date-released fields
    yaml_file[CITATION_FILE_VERSION_FIELD] = version_number
    yaml_file[CITATION_FILE_DATE_FIELD] = _convert_text_date_to_date(
        version_month, version_year, version_day)

    # rewrite citation file with updated fields
    with io.open(citation_file_path, 'w', encoding='utf8') as outfile:
        yaml.dump(yaml_file, outfile, default_flow_style=False,
                  allow_unicode=True)


def _convert_text_date_to_date(version_month, version_year, version_day):
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
        version_year, _convert_month_name_to_number(version_month), version_day)


def _convert_month_name_to_number(version_month):
    """ converts a python month in text form to a number form
    
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
