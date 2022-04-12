import os
import shutil


def check_setup(root):
    full_path = os.path.join(root, "setup.py")
    with open(full_path, "r") as setup:
        for line in setup:
            if "name=" in line:
                parts = line.split('"')
                return parts[1]


def get_version_from_file(root, name):
    full_path = os.path.join(root, name)
    with open(full_path, "r") as version_file:
        for line in version_file:
            if "__version__" in line:
                parts = line.split('"')
                return parts[1]


def get_version_from_directory(realpath):
    for root, dirs, files in os.walk(realpath, topdown=True):
        if "_version.py" in files:
            return get_version_from_file(root, "_version.py")
        if "version.py" in files:
            return get_version_from_file(root, "version.py")
    raise Exception("No version found in ", realpath)


def get_versions(realpath):
    versions = dict()

    for root, dirs, files in os.walk(realpath, topdown=True):
        if "application_generated_data_files" in dirs:
            folder = os.path.join(root, "application_generated_data_files")
            print(folder)
            shutil.rmtree(folder)
            dirs.remove("application_generated_data_files")
        if "reports" in dirs:
            folder = os.path.join(root, "reports")
            print(folder)
            shutil.rmtree(folder)
            dirs.remove("reports")
        if ".git" in dirs:
            dirs.remove(".git")
        if ".idea" in dirs:
            dirs.remove(".idea")
        # print root, files
        if "setup.py" in files:
            print(root)
            name = check_setup(root)
            version = get_version_from_directory(root)
            versions[name] = version
            print("\t", name, version)
            dirs[:] = []
    return versions


def verify_version(declaration, versions):
    parts = declaration.split(" ")
    print(parts)
    if parts[0] in versions:
        version = versions[parts[0]]
        if parts[1] != ">=":
            raise Exception("Not >=", declaration)
        if parts[2][:-1] != version:
            raise Exception("For", parts[0], "mismatch", parts[2][:-1],
                            version)
        if len(parts) > 3:
            if parts[3] == "<=":
                if parts[4][:-1] != version:
                    raise Exception("For", parts[0], "<= mismatch",
                                    parts[4][:-1], version)
            if parts[3] == "<":
                prefix = ""
                chunks = parts[4].split(".")
                major = chunks[0]
                if major[:2] == "1!":
                    major = major[2:]
                    prefix = "1!"
                if major[0] == "v":
                    raise Exception("V in version")
                major = int(major)
                if chunks[1] != "0":
                    raise Exception("None minor not zero")
                if chunks[2] != "0":
                    raise Exception("None minor not zero")
                chunks = version.split(".")
                previous = chunks[0]
                if previous[:2] == "1!":
                    previous = previous[2:]
                    if prefix != "1!":
                        raise Exception("Prefix clash")
                else:
                    if prefix != "":
                        raise Exception("Prefix clash")
                if previous[0] == "v":
                    raise Exception("V in version")
                previous = int(previous)
                if major != previous + 1:
                    raise Exception("Not an major bump", declaration)
                if chunks[1] != "0":
                    raise Exception("None minor not zero")
                if chunks[2] != "1":
                    raise Exception("None minor not zero")


def setup_versions(realpath, versions):
    for root, dirs, files in os.walk(realpath, topdown=True):
        if ".git" in dirs:
            dirs.remove(".git")
        if ".idea" in dirs:
            dirs.remove(".idea")
        # print root, files
        if "setup.py" in files:
            full_path = os.path.join(root, "setup.py")
            print(full_path)
            install = False
            with open(full_path, "r") as setup:
                for line in setup:
                    if "install_requires=[" in line:
                        install = True
                    if "install_requires = [" in line:
                        install = True
                    if install:
                        parts = line.split("'")
                        if len(parts) > 1:
                            verify_version(parts[1], versions)
                    if "]" in line:
                        install = False

            full_path = os.path.join(root, "requirements.txt")
            print(full_path)
            with open(full_path, "r") as requirements:
                for line in requirements:
                    parts = line.split("'")
                    if len(parts) > 1:
                        verify_version(parts[1], versions)

            dirs[:] = []


realpath = os.path.realpath("../")
versions = get_versions(realpath)
setup_versions(realpath, versions)
