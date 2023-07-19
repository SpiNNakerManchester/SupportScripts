#!/usr/bin/perl

# Copyright (c) 2023 The University of Manchester
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

# Assumes all repositories master/main locally are upto date including C build
# This script can be safely be repeated until the $release pushed to pypi or tagged

my $release = "7.0.0";  # Without the leading 1!

use strict;
use warnings;
use Cwd qw(getcwd);
use feature qw(say);
use File::Basename;
use File::Find qw(find);
use File::Path;
use Git;
use LWP::Simple;
use POSIX qw(strftime);

my $changed;
my $in;
my $line;
my $new_path;
my $path;
my $permissions;
my $out;
my $repo;
my $start_path ;

sub git_test_pypi{
    # Switch to the main and master branch and make sure is it uptodate
    $repo = Git->repository();

    $repo->command('checkout', 'test.pypi-last-pre');
}

sub git_main{
    # Switch to the main and master branch and make sure is it uptodate
    $repo = Git->repository();

    $repo->command('fetch', 'origin');
    my $info = $repo->command('branch');
    if (index($info, 'main') != -1){
        $repo->command('checkout', 'main');
        $repo->command('merge', 'origin/main', 'main');
    } else {
        $repo->command('checkout', 'master');
        $repo->command('merge', 'origin/master', 'master');
    }
}

sub git_setup_branch{
    # clears previous versions of the branch and creates a new one.
    # the eval is because check if release essist may have a flase possitive
    # Especially if doing a full release while an alpha is still in Jenkins

    $repo->command('fetch');

    # remove previously branches
    my $info = $repo->command('branch');
    if (index($info, $release) != -1){
        say "removing previous branch $release";
        eval {
            $repo->command('branch', '-D', $release);
        } or do {
            my $e = $@;
            say "Something went wrong: $e#";
        };
    }

    $info = $repo->command('ls-remote', '--heads', 'origin');
    if (index($info, $release) != -1){
        say "removing previous remote branch";
        eval {
            $repo->command('push', "origin", "--delete", $release);
        } or do {
            my $e = $@;
            say "Something went wrong: $e#";
        };
    }

    # Move to release branch
    $repo->command('branch', $release);
    $repo->command('checkout', $release);
}

sub git_push_branch{
    # Pushes the release as a branch
    $repo->command('push', 'origin', $release);
    git_main();
    $repo->command('branch', '-D', $release);
}

sub start_copy{
    # starts the copy by creating a new bak file
    # Opens the original or reading and the bak for writing
    open $in,  '<', $path     or die "Can't read old file: $path";
    $permissions = (stat $path)[2] & 00777;
    $new_path = "${path}.bak";
    open $out, '>', $new_path or die "Can't write new file: $new_path";
    $changed = 0 # Perl has no bool type so use 0 as false
}

sub finish_copy{
    # closes the file streams
    # If needed replaces the original with the new file and does a git commit
    # removes the new (.bak) file
    close $in;
    close $out;
    if ($changed){
        say "Updated: ",$path;
        unlink $path;
        rename $new_path, $path;
        chmod $permissions, $path;
        $repo->command('commit', $path, '-m', "info for release ${release}");
    } else {
        unlink $new_path;
    }
}

sub handle_setup_cfg {
    # looks for any line withe the spinnaker version pattern
    # and updates to current version
    $path = File::Spec->catfile(getcwd(), "setup.cfg");
    if (not -e $path) {
        say "no ", $path;
        return;
    }
    start_copy();
    while( <$in> ) {
        $line = $_;
        $line =~ s/( == 1!\d.\d.\d.*)/ == 1!${release}/;
        print $out $line;
        $changed = $changed || $line ne $_;
    }
    finish_copy();
}

sub handle_version{
    # updates version num and dates in _version.pl file

    #$path set by caller

    start_copy();
    $line = <$in>;
    if (!defined $line){
        print("No __version line found\n");
        die $path;
    }
    while ($line !~ /\_\_version/i){
        print $out $line;
        $line = <$in>;
        if (!defined $line){
            print("No __version line found\n");
            die $path;
        }
    }

    if (index($line, $release) == -1){
        $changed = 1;
        while ($line !~ /\_\_version\_name\_\_/i){
            $line = <$in>;
            if (!defined $line){
                print("No __version_name__ line found\n");
                die $path;
            }
        }

        print $out "__version__ = \"1!${release}\"\n";
        my $month = strftime "%B", localtime;
        print $out "__version_month__ = \"${month}\"\n";
        my $year = strftime "%Y", localtime;
        print $out "__version_year__ = \"${year}\"\n";
        my $day = strftime "%d", localtime;
        print $out "__version_day__ = \"${day}\"\n";
        print $out "__version_name__ = \"Revisionist\"\n";

        while( <$in> ) {
            print $out $_;
        }
    }
    finish_copy();
}


sub handle_readme {
    # Updates the README.md file
    # change readthedocs.io link to version specific

    $path = File::Spec->catfile(getcwd(), "README.md");
    if (not -e $path) {
        say "no ", $path;
        return;
    }
    start_copy();
    while( <$in> ) {
        $line = $_;
        if ($line =~ /^\[\!\[/) {
            $line = ""
        }
        $line =~ s/readthedocs\.io\)$/readthedocs\.io\/en\/${release}\)/;
        $changed = $changed || $line ne $_;
        print $out $line;
    }
    finish_copy();
}

sub handle_jenkins {
    # update Jenkins file to use a specific version
    $path = File::Spec->catfile(getcwd(), "Jenkinsfile");
    start_copy();
    my $release2 = $release;
    $release2 =~ s/-//;
    while( <$in> ) {
        $line = $_;
        $line =~ s/ --pre/==1!${release2}/;
        $changed = $changed || $line ne $_;
        print $out $line;
    }
    finish_copy();
   say $release;
}

sub handle_conf_py {
    # update doc/source/conf.py file
    # Updates various lines with version

    $path = File::Spec->catfile(getcwd(), "doc", "source", "conf.py");
    if (not -e $path) {
        return;
    }

    start_copy();
    # assume only a single digit sub release
    my $version = substr($release, 0, 3);
    while( <$in> ) {
       $line = $_;
       my $old_line = $line;
       $line =~ s/(\d{4})\-(\d{4})/$1\-2023/i;
       $line =~ s/version = \'\d.\d.*$/version = \'1!${version}\'/;
       $line =~ s/release = \'\d.\d.*$/release = \'1!${release}\'/;
       $line =~ s/spinnaker_doc_version = "latest"/spinnaker_doc_version = "${release}"/;
       $changed = $changed || $line ne $_;
       print $out $line;
    }
    finish_copy();
}

sub handle_doc_requirements_txt {
    # updates doc/doc_requirements.txt
    # use the version specific branches for dependecies dependencies

    $path = File::Spec->catfile(getcwd(), "doc", "doc_requirements.txt");
    if (not -e $path) {
        return;
    }

    start_copy();
    while( <$in> ) {
       $line = $_;
       my $old_line = $line;
       $line =~ s/\@master#/\@${release}#/;
       $changed = $changed || $line ne $_;
       print $out $line;
    }
    finish_copy();
}

sub handle_index_rst {
    # Updates the index.rst by changing readthedoc links to version specific

    # $path set by caller
    start_copy();
    while( <$in> ) {
        $line = $_;
        $line =~ s/readthedocs\.io(.*)$/readthedocs\.io\/en\/${release}/;
        $changed = $changed || $line ne $_;
        print $out $line;
    }
    finish_copy();
}

sub handle_pom {
    # Updates Java pom.xml changes <version> to current release

    # $path set by caller
    say $path ;
    start_copy();
    while( <$in> ) {
        $line = $_;
        $line =~ s/(version>)(.*)(-SNAPSHOT)/$1$release/;
        $changed = $changed || $line ne $_;
        print $out $line;
    }
    finish_copy();
}

sub handle_doxyfile {
    # Updates Doxyfile changing PROJECT_NUMBER to version

    # $path set by caller
    say $path ;
    if (index($path, "spinnaker_tools") != -1){
        return;
    }
    start_copy();
    while( <$in> ) {
        $line = $_;
        $line =~ s/(PROJECT_NUMBER\s*\=\s*)(\w.*)$/$1$release/;
        $changed = $changed || $line ne $_;
        print $out $line;
    }
    finish_copy();
}

sub do_build{
    # clears any previous python build and does a new one
    $path = File::Spec->catfile(getcwd(), "setup.py");
    if (not -e $path) {
        return;
    }
    rmtree("dist");
    system("python3 -m build >nul");
}

sub find_and_handle_special{
    $path = $File::Find::name;
    if (basename($path) eq "_version.py"){
         handle_version();
    } elsif (basename($path) eq "index.rst"){
         handle_index_rst();
    } elsif (basename($path) eq "pom.xml"){
         handle_pom();
    } elsif (basename($path) eq "Doxyfile"){
         handle_doxyfile();
    }
    # pom.xml
    # Doxyfile but not tools
}

sub update_directory{
    # Moves into directory, updates version, builds and commits
    $start_path = getcwd();
    chdir $_[0];
    say "updating", getcwd();

    # switch to main or master branch
    git_main();
    git_setup_branch();

    handle_setup_cfg();
    find(\&find_and_handle_special, getcwd());
    handle_conf_py();
    handle_doc_requirements_txt();
    handle_readme();

    do_build();

    git_push_branch();
    chdir $start_path;
}

sub update_integration_tests{
    # creates a test branch based on branch setup for test pypi
    $start_path = getcwd();
    chdir $_[0];
    say "updating", getcwd();

    git_test_pypi();
    git_setup_branch();
    handle_jenkins();

    # Do not push, or delete the branch
    chdir $start_path;
}

sub wait_doc_built{
    # Blocks the script to make sure the readthedocs build finished
    my $url = "https://${_[0]}.readthedocs.io/en/${release}/";
    say $url;

    my $browser = LWP::UserAgent->new;

    my $timeout = 30;
    my $response = $browser->get( $url );
    while  (index($response->status_line, "200") == -1) {
        my $status = $response->status_line;
        say "$url gave $status waiting ${timeout}s";
        sleep($timeout);
        $response = $browser->get( $url );
    }
}

update_directory("../spinnaker_tools");
update_directory("../spinn_common");
update_directory("../SpiNNUtils");
wait_doc_built('spinnutils');
update_directory("../SpiNNMachine");
wait_doc_built('spinnmachine');
update_directory("../SpiNNMan");
wait_doc_built('spinnman');
update_directory("../spalloc");
update_directory("../spalloc_server");
update_directory("../PACMAN");
wait_doc_built('spalloc');
wait_doc_built('pacman');
update_directory("../SpiNNFrontEndCommon");
update_directory("../TestBase");
wait_doc_built('spinnfrontendcommon');
update_directory("../sPyNNaker");
update_directory("../SpiNNakerGraphFrontEnd");
update_directory("../PyNN8Examples");
update_directory("../IntroLab");
update_directory("../sPyNNaker8NewModelTemplate");
update_directory("../sPyNNakerVisualisers");
update_directory("../Visualiser");
update_directory("../JavaSpiNNaker");
update_directory("../RemoteSpiNNaker");
update_directory("../SpiNNGym");
update_directory("../SpiNNaker_PDP2");
update_directory("../microcircuit_model");
update_directory("../MarkovChainMonteCarlo");
update_directory("../sPyNNaker8Jupyter");
wait_doc_built('spynnaker');
wait_doc_built('spinnakergraphfrontend');
update_directory("../sphinx8");
update_integration_tests("../IntegrationTests");
# die "stop";

