import os
from shutil import copyfile

code_directory = os.path.dirname(__file__)
module_directory = os.path.dirname(code_directory)
new_version = os.path.join(module_directory, "version", "version.py")
root_directory = os.path.dirname(module_directory)


def find_version(version_file):
    with open(version_file, 'r') as f:
        for line in f:
            if "__version__" in line:
                if "import" in line:
                    return None
                parts = line.split("\"")
                # print parts
                version = parts[1]
                if "!" in version:
                    return version
                else:
                    return None
    raise Exception("Unable to find__version__ in {}".format(version_file))


def change_version_files():
    for dirName, subdirList, fileList in os.walk(root_directory):
        for fname in fileList:
            if fname == "_version.py":
                version_file = os.path.join(dirName, fname)
                version = find_version(version_file)
                if version:
                # print(version_file, version)
                    os.remove(version_file)
                    copyfile(new_version, version_file)
                    print(version_file, version)


def find_name_in_setup(setup_file):
    with open(setup_file, 'r') as f:
        for line in f:
            if "name=" in line:
                parts = line.strip().split("=")
                return parts[1].replace('"', '').replace(',', '')


def get_setup_names():
    global names
    names = []
    for name in os.listdir(root_directory):
        setup = os.path.join(root_directory, name, "setup.py")
        if os.path.isfile(setup):
            names.append(find_name_in_setup(setup))
    print(names)


def needs_recquirement_version_bump(file):
    with open(file, 'r') as f:
        for line in f:
            for name in names:
                if name in line:
                    if previous in line:
                        print(line.replace(previous, current))
                        return True

    return False


def bump_requirement_version(file):
    with open(file, 'r') as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        for name in names:
            if name in line:
                lines[i] = line.replace(previous, current)
                print(lines[i])
    with open(file, 'w') as f:
        f.writelines(lines)


def check_versions(dir_name, file_name):
    file = os.path.join(root_directory, dir_name, file_name)
    if not os.path.isfile(file):
        return
    print(file)
    if needs_recquirement_version_bump(file):
        bump_requirement_version(file)


def bump_required_version():
    for dir_name in os.listdir(root_directory):
        check_versions(dir_name, "setup.py")
        check_versions(dir_name, "requirements.txt")
        check_versions(dir_name, "requirements-test.txt")


def bump_conf_version(file):
    with open(file, 'r') as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        if line.startswith("version = "):
            lines[i] = "version = '6.0'\n"
        elif line.startswith("release ="):
            lines[i] = "release = '6.0.1'\n"
        elif line.startswith("copyright ="):
            lines[i] = "copyright = u'2014-2021'\n"
        elif line.startswith("copyright = u'2014-2021'"):
            lines[i] = "epub_copyright = u'2014-2021'\n"
    with open(file, 'w') as f:
        f.writelines(lines)


def bump_doc_configs():
    for dir_name in os.listdir(root_directory):
        # The spalloc ones are different but also in a docs folder
        file = os.path.join(
            root_directory, dir_name, "doc", "source", "conf.py")
        if not os.path.isfile(file):
            continue
        bump_conf_version(file)


previous = ">= 1!5.1.1, < 1!6.0.0"
current = "== 1!6.0.1"
change_version_files()
get_setup_names()
bump_required_version()
bump_doc_configs()
