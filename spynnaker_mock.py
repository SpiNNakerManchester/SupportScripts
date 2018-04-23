from __future__ import print_function

population_count = 0
projection_count = 0
is_setup = False
print_status_messages = True


class Population(object):

    def __init__(self):
        global population_count
        if not is_setup:
            raise Exception("not setup")
        population_count += 1
        self.id = population_count
        if print_status_messages:
            print("created ", self)

    def __str__(self):
        return "Population:{}".format(self.id)


class Projection(object):
    def __init__(self):
        global projection_count
        if not is_setup:
            raise Exception("not setup")
        projection_count += 1
        self.id = projection_count
        if print_status_messages:
            print("created ", self)

    def __str__(self):
        return "Projection:{}".format(self.id)


def setup():
    global population_count, projection_count, is_setup
    if is_setup:
        raise Exception("already setup")
    population_count = 0
    projection_count = 0
    is_setup = True
    if print_status_messages:
        print("setup successful")


def population():
    return Population()


def projection():
    return Projection()


def run():
    if not is_setup:
        raise Exception("not setup")
    if print_status_messages:
        print("population:", population_count, " projection", projection_count)


def end():
    global is_setup
    if not is_setup:
        raise Exception("not setup")
    is_setup = False
    if print_status_messages:
        print("end successful")
