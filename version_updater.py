from datetime import date
import datetime

from enum import Enum

VERSION_FILE = "_version.py"

# c magic params
C_VERSION_NUM = "SLLT_VER_STR"
C_VERSION_NUM_HEX = "SLLT_VER_NUM"
C_VERSION_MONTH = "SLLT_VER_MON"
C_VERSION_DAY = "SLLT_VER_DAY"
C_VERSION_YEAR = "SLLT_VER_YEAR"
C_VERSION_NAME = "SLLT_VER_NAME"
C_HASH_DEFINE = "#define"

# python magic params
PYTHON_VERSION_NUM = "__version__ = "
PYTHON_VERSION_MONTH = "__version_month__ = "
PYTHON_VERSION_YEAR = "__version_year__ = "
PYTHON_VERSION_DAY = "__version_day__ = "
PYTHON_VERSION_NAME = "__version_name__ = "

VERSION_EPOCH = "1!"

LANGUAGE_CODES = Enum(
    value="LANGUAGE_CODES",
    names=[
        ("PYTHON", 0),
        ("C", 1)])


def update_version_file(language, version_path, major, minor, patch, name):
    today = str(date.today())
    date_bits = today.split("-")
    month_text = datetime.datetime.now().strftime("%B")

    version_number = None
    version_year = date_bits[0]
    version_day = date_bits[2]
    version_month = month_text

    version_file = open(version_path, "r")
    in_lines = version_file.readlines()
    version_file.close()

    output_file = open(version_path, "w")

    for in_line in in_lines:
        if language == LANGUAGE_CODES.PYTHON:
            if len(in_line.split(PYTHON_VERSION_DAY)) != 1:
                output_file.write(PYTHON_VERSION_DAY + "\"{}\"".format(
                    version_day) + "\n")
            elif len(in_line.split(PYTHON_VERSION_MONTH)) != 1:
                output_file.write(PYTHON_VERSION_MONTH + "\"{}\"".format(
                    month_text) + "\n")
            elif len(in_line.split(PYTHON_VERSION_NAME)) != 1:
                output_file.write(PYTHON_VERSION_NAME + "\"{}\"".format(name)
                                  + "\n")
            elif len(in_line.split(PYTHON_VERSION_YEAR)) != 1:
                output_file.write(PYTHON_VERSION_YEAR + "\"{}\"".format(
                    version_year) + "\n")
            elif len(in_line.split(PYTHON_VERSION_NUM)) != 1:
                version_number = _update_version_number(
                    in_line.split(PYTHON_VERSION_NUM)[1], major, minor, patch)
                output_file.write(PYTHON_VERSION_NUM + "\"{}\"".format(
                    version_number) + "\n")
            else:
                output_file.write(in_line)
        elif language == LANGUAGE_CODES.C:
            if len(in_line.split(C_VERSION_DAY)) != 1:
                output_file.write(C_HASH_DEFINE + C_VERSION_DAY + " " +
                                  "\"{}\"".format(version_day) + "\n")
            elif len(in_line.split(C_VERSION_MONTH)) != 1:
                output_file.write(C_HASH_DEFINE + C_VERSION_MONTH + " " +
                                  "\"{}\"".format(version_month) + "\n")
            elif len(in_line.split(C_VERSION_NAME)) != 1:
                output_file.write(C_HASH_DEFINE + C_VERSION_NAME + " " +
                                  "\"{}\"".format(name) + "\n")
            elif len(in_line.split(C_VERSION_YEAR)) != 1:
                output_file.write(C_HASH_DEFINE + C_VERSION_YEAR + " " +
                                  "\"{}\"".format(version_year) + "\n")
            elif len(in_line.split(C_VERSION_NUM)) != 1:
                version_number = _update_version_number(
                    in_line.split(C_VERSION_NUM)[1], major, minor, patch)
                output_file.write(C_HASH_DEFINE + C_VERSION_NUM + " " +
                                  "\"{}\"".format(version_number) + "\n")
            elif len(in_line.split(C_VERSION_NUM_HEX)) != 1:
                version_bits = version_number.split(".")
                output_file.write(
                    C_HASH_DEFINE + C_VERSION_NUM_HEX + " " + "0x0" +
                    version_bits[0] + "0" + version_bits[1] + "0" +
                    version_bits[2] + "\n")
            else:
                output_file.write(in_line)
        else:
            raise Exception("WTF")
    output_file.flush()
    output_file.close()
    return version_number, version_month, version_year, version_day


def _update_version_number(version_number, major, minor, patch):
    version_num_bits = version_number.split(".")
    previous_patch = int(
        version_num_bits[2].replace('"', "").strip("\n").
        replace("'", "").replace("\t", ""))
    previous_minor = int(
        version_num_bits[1].replace('"', "").strip("\n").replace("'", "")
        .replace("\t", ""))

    saw_epoch = False
    if len(version_num_bits[0].split(VERSION_EPOCH)) != 1:
        previous_major = int(version_num_bits[0].split("!")[1].replace('"', "")
                             .strip("\n").replace("'", "").replace("\t", ""))
        saw_epoch = True
    else:
        previous_major = int(
            version_num_bits[0].replace('"', "").strip("\n").replace("'", "")
            .replace("\t", ""))

    if patch:
        previous_patch += 1
    if minor:
        previous_minor += 1
    if major:
        previous_major += 1

    new_version_num = (
        str(previous_major) + "." + str(previous_minor) + "." +
        str(previous_patch))
    if saw_epoch:
        new_version_num = VERSION_EPOCH + new_version_num
    return new_version_num




