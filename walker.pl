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

use strict;
use warnings;
use feature qw(say);
use Cwd qw(getcwd);
use File::Find qw(find);
use File::Basename;
use File::Spec;
use File::Copy;
use Git;
use List::Util qw(min);

my @ignore_dirs = (
    '/__pyache__/',,
    '/.git/',
    '/.idea/',
    '/doc/build/',
#    '/support/',
    '/dist/',
    '\.egg-info/',
    '\.ratexclude',
    'project$',
    '.pyc',
    '.travis.yml$',
    '/modified_src/',
    '/.settings/',
    'cache/',
    '/MANIFEST.in$',
    '/pypi_to_import$',
    '/target/',
    '/SpiNNaker-allocserv/src/main/frontend/node_modules/typescript/',
    '.png$',
    'README.md',
     );

my $path;
my $line;
my $new_path;
my $permissions;
my $prefix;
my $in;
my $out;
my $repo;
my $changed;
my $old_line;
my $main_repository;
my $release = 0;   # if zero skips any tasks related to a release

sub fix_top_line{
    $old_line = $line;
    # change it to YYYY-2023
    $line =~ s/copyright(.*)(\d{4})(.*)(\d{4})(.*)the university of manchester/Copyright (c) $2 The University of Manchester/i;
    $line =~ s/copyright(\D*)(\d{4})(\D*)the university of manchester/Copyright (c) $2 The University of Manchester/i;

    # Find when copyright starts
    my $original_st = $line;
    $original_st =~ s/^(\D)+(\d{4})(.*)/$2/i;
    my $original = int($original_st);

    # Find when file first created in giut
    my $info = $repo->command('log', '--diff-filter=AC', '--follow', '--format=%aD', '-1', $path);
    if (length($info) > 10){
        my $year_st = $info;
        $year_st =~ s/^(.*)\s(\d{4})(.*)/$2/i;
        my $year = int($year_st);
        if (int($original) > int($year_st)){
            say int($original)," ", int($year_st), " ", $path;
            say $line;
            $line =~ s/copyright(.*)(\d{4}) the university of manchester/Copyright (c) ${year} The University of Manchester/i;
            say $line;
        }
    }

    # remove double same year
    #$line =~ s/(.*) 2023-2023(.*)/$1 2023$2/i;

    # check the line
    #check_line('Copyright \(c\) (\d{4}-)?2023 The University of Manchester(\s)$');
    print $out $line;
    $changed = $line ne $old_line
}

sub check_line{
    if ($line !~ $_[0]) {
        print("Found unexpected line:\n");
        print($line);
        print("expected\n");
        print( $_[0],"\n");
        die $path;
    }
}

sub handle_top_lines{
    $line = <$in>;
    if (!defined $line){
        print("No copyright line found\n");
        die $path;
    }
    # skip: //! \copyright      &copy; The University of Manchester - 2012-2015
    while ($line !~ /copyright (.)*The University of Manchester(\s)*$/i){
        print $out $line;
        $line = <$in>;
        if (!defined $line){
            if ($path =~ /java\-header\.txt/){
                return;
            }
            print("No copyright line found\n");
            die $path;
        }
    }

    fix_top_line();
}

sub munch_existing_gnu {
    $line = <$in>;
    # keep any additional lines
     while (length($line) > 5){
        print $out $line;
        $line = <$in>;
    }
    while (length($line) < 5){
        $line = <$in>;
    }
    $prefix = $line;
    $prefix =~ s/^(\s*)(\S+)(.*)(\s+)$/$1$2/;
    check_line('This program is free software: you can redistribute it and/or modify');
    $line = <$in>;
    check_line('it under the terms of the GNU General Public License as published by');
    $line = <$in>;
    check_line('the Free Software Foundation, either version 3 of the License, or');
    $line = <$in>;
    check_line('\(at your option\) any later version.');
    $line = <$in>;
    while (length($line) < 5){
        $line = <$in>;
    }
    check_line('This program is distributed in the hope that it will be useful,');
    $line = <$in>;
    check_line('but WITHOUT ANY WARRANTY; without even the implied warranty of');
    $line = <$in>;
    check_line('MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the');
    $line = <$in>;
    check_line('GNU General Public License for more details.');
    $line = <$in>;
    while (length($line) < 5){
        $line = <$in>;
    }
    check_line('You should have received a copy of the GNU General Public License');
    $line = <$in>;
    check_line('along with this program.  If not, see <https://www.gnu.org/licenses/>.(\s+)$');
}

sub start_copy{
    open $in,  '<', $path     or die "Can't read old file: $path";
    $permissions = (stat $path)[2] & 00777;
    $new_path = "${path}.bak";
    open $out, '>', $new_path or die "Can't write new file: $new_path";
    $changed = 0 # Perl has no bool type so use 0 as false
}

sub finish_copy{
    close $in;
    close $out;
    if ($changed){
        say "Updated: ",$path;
        unlink $path;
        rename $new_path, $path;
        chmod $permissions, $path;
    } else {
        unlink $new_path;
    }
}

sub handle_gnu_file {
    if (basename($path) eq "walker.pl"){
       return;
    }
    if ($path =~ /check\-copyrights/){
        return;
    }
    say "GNU ", $path;
    start_copy();
    handle_top_lines();
    munch_existing_gnu();

    print $out "${prefix}\n";
    print $out "${prefix} Licensed under the Apache License, Version 2.0 (the \"License\");\n";
    print $out "${prefix} you may not use this file except in compliance with the License.\n";
    print $out "${prefix} You may obtain a copy of the License at\n";
    print $out "${prefix}\n";
    print $out "${prefix}     https://www.apache.org/licenses/LICENSE-2.0\n";
    print $out "${prefix}\n";
    print $out "${prefix} Unless required by applicable law or agreed to in writing, software\n";
    print $out "${prefix} distributed under the License is distributed on an \"AS IS\" BASIS,\n";
    print $out "${prefix} WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n";
    print $out "${prefix} See the License for the specific language governing permissions and\n";
    print $out "${prefix} limitations under the License.\n";
    while( <$in> ) {
        print $out $_;
    }
    $changed = 1; # Perl has no bool so using 1 for value
    finish_copy();
}

sub fix_copyright_year {
    # say "gnu: ", $path;
    start_copy();

    handle_top_lines();
    if ($changed) {
        while( <$in> ) {
            print $out $_;
        }
    }
    finish_copy();
}

sub fix_http {
    if (-d) {
        return;
    }
    $path = $File::Find::name;

    # ignore the weird directories
    foreach my $pattern (@ignore_dirs){
        if ($path =~ $pattern) {
            return;
        }
    }
    if ($path =~ /\.bak$/){
        return;
    }
    if (basename($path) eq "walker.pl"){
       return;
    }

    start_copy();
    my $unaccepable_http = 0;
    while( <$in> ) {
        $line = $_;
        if ($line =~ /http\:/){
            # these have all be checked to serve https
            $line =~ s/http\:\/\/(cxf\.apache\.org)(.*)(.xsd)/https\:\/\/$1$2$3/i;
            $line =~ s/http\:\/\/(www\.apache\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(maven\.apache\.org\/xsd\/)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(developer\.apple\.com)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.blackpawn\.com)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(fasaxc\.blogspot\.co\.uk)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(journal\.frontiersin\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(cairographics\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(daringfireball\.net)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(dx\.doi\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(ieeexplore\.iee\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(fsf\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.gnu\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(groups\.google\.com)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.graphviz\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(infocenter\.arm\.com)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.java\.com)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.johndcook\.com)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(jupyter\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.jupyter\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.cs\.man\.ac\.uk)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(\w+\.cs\.manchester\.ac\.uk)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(\w*\.mathjax\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.mcternan\.me\.uk)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(\w+\.microsoft\.com)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.mirrorservice\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(mirror\.ox\.ac\.uk)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(neuralensemble\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.oasis-open\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.opengl\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.opensourcebrain\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(orcid\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(pytest\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(docs\.python\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(qt-project\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/([\w\-]+\.readthedocs\.\w+)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.riverbankcomputing\.co\.uk)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(autogen\.sf\.net)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(sourceforge\.net)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(autogen\.sourceforge\.net)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(spinnakermanchester\.github\.io)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.springframework\.org)(.*)(.xsd)/https\:\/\/$1$2$3/i;
            $line =~ s/http\:\/\/(sphinx-doc\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.sphinx-doc\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(java\.sun\.com)(.*)(.xsd)/https\:\/\/$1$2$3/i;
            $line =~ s/http\:\/\/(java\.sun\.com\/docs)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(java\.sun\.com\/j2se)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.sussex\.ac\.uk)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(www\.telegraph\.co\.uk)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(en\.wikipedia\.org)/https\:\/\/$1/i;
            $line =~ s/http\:\/\/(xapian\.org)/https\:\/\/$1/i;
            # these need fixing as broken
            $line =~ s/http\:\/\/docs\.mathjax\.org\/en\/latest\/output\.html/https\:\/\/docs\.mathjax\.org/i;

            $changed = $changed || $line ne $_;
            if ($line =~ /http\:/){
                # These we can not guarantee will have https
                if ($line =~ /http\:\/\/127\./){
                } elsif ($line =~ /http\:\/\/localhost/){
                } elsif ($line =~ /http\:\/\/\[/){
                    #http://[your ip]:8000
                } elsif ($line =~ /http\:\/\/\{/){
                    # http://{jupyter_ip}:{jupyter_port}/services/
                } elsif ($line =~ /http\:\/\/compneuro\.uwaterloo.ca/){
                    # does not support https
                } elsif ($line =~ /http\:\/\/jhnet\.co\.uk/){
                    # does not support https
                } elsif ($line =~ /http\:\/\/data\.andrewdavison.info/){
                    # broken link
                } elsif ($line =~ m/http\:\/\/checkstyle\.sourceforge\.net\/dtds\//){
                    # uri not a url
                } elsif ($line =~ m/http\:\/\/(www\.springframework\.org\/schema\/)(\w+)(\s)/){
                    # uri not a url
                } elsif ($line =~ m/http\:\/\/(www\.w3\.org\/2001\/XMLSchema-instance\s)/){
                    # uri not a url
                } elsif ($line =~ m/http\:\/\/(java\.sun\.com\/xml\/)([\/\w]+)(\s)/){
                    # uri not a url
                } elsif ($line =~ m/http\:\/\/(cxf\.apache\.org\/)([\/\w]+)(\s)/){
                    # uri not a url
                } elsif ($line =~ /\<project xmlns=/){
                    # flags a uri line
                } elsif ($line =~ /\"\$schema\"/){
                    # flags a uri line
                } elsif ($line =~ /xsi\:schemaLocation/){
                    # flags a uri line
                } elsif ($line =~ /\%\@ taglib prefix=/){
                    # flags a uri line
                } elsif ($line =~ /xmlns/){
                    # flags a uri line
                } elsif ($line =~ /\(\"http\:\/\/\"\)/){
                   # .startsWith("http://")
                } else {
                    print $line;
                    $unaccepable_http = 1;
                }
            }
       }

       print $out $line;
    }
    if ($unaccepable_http) {
        say "Unexpected http: ", $path;
    }
    finish_copy();
}

sub fix_each_file{
    if (-d) {
        return;
    }
    $path = $File::Find::name;

    # ignore the weird directories
    foreach my $pattern (@ignore_dirs){
        if ($path =~ $pattern) {
            return;
        }
    }
    # ignore the LICENSE.md mentions copyright but has none
    if ($path =~ /\.bak$/){
        return;
    }
    # warning can not grep the same open file twice!
    open(FILE, $path) or die "Can't open: $path!\n";
    if (grep{/http\:\/\//} <FILE>){
       fix_http();
    }
    if ($path =~ /LICENSE/){
        return;
    }

    # fix version files
    if (basename($path) eq "_version.py"){
        if ($release) {
            handle_version();
        }
    }

    # warning can not grep the same open file twice!
    open(FILE, $path) or die "Can't open: $path!\n";
    if (grep{/GNU General Public License/} <FILE>){
        if ($main_repository){
            handle_gnu_file();
        } else {
           fix_copyright_year();
        }
    }
    # warning can not grep the same open file twice!
    open(FILE, $path) or die "Can't open: $path!\n";
    if (grep{/Apache License/} <FILE>){
       fix_copyright_year();
   }

}

sub handle_dependencies {
    if (not -e $path) {
        return;
    }
    start_copy();
    $new_path = "${path}.bak";
    #say "setup: ", $new_path;
    open $in,  '<', $path     or die "Can't read old file: $path";
    open $out, '>', $new_path or die "Can't write new file: $new_path";
    while( <$in> ) {
       $line = $_;
       if ($main_repository) {
           $line =~ s/GNU General Public License v3 \(GPLv3\)/Apache License 2.0/i;
           $line =~ s/GNU General Public License v2 \(GPLv2\)/Apache License 2.0/i;
           $line =~ s/GNU GPLv3.0/Apache License 2.0/i;
       }
       $line =~ s/( == 1!\d.\d.\d)/ == ${release}/;
       print $out $line;
       $changed = $changed || $line ne $_;
    }
    finish_copy();
}

sub handle_license {
    $path = File::Spec->catfile(getcwd(), "LICENSE");
    my $s_l_path = File::Spec->catfile(dirname(getcwd()), "SupportScripts", "LICENSE");
    if ($s_l_path ne $path) {
        unlink $path;
        copy($s_l_path, $path) or die "LICENSE copy failed: $!";
    }

    $path = File::Spec->catfile(getcwd(), "LICENSE_POLICY.md");
    my $old_path = File::Spec->catfile(getcwd(), "LICENSE.md");
    if (-e $old_path) {
        copy($old_path, $path) or die "LICENSE copy failed: $!";
        unlink $old_path;
        $repo->command('add', "LICENSE_POLICY.md");
    }

    if (-e $path) {
        start_copy();
        while( <$in> ) {
           $line = $_;
           $line =~ s/GPL version 3 license/Apache License 2.0/i;
           # http://www.gnu.org/copyleft/gpl.html
           $line =~ s/http(.*)www.gnu.org(.*)html/https:\/\/www.apache.org\/licenses\/LICENSE\-2\.0/i;
           $line =~ s/common_pages\/4\.0\.0/latest/;
           print $out $line;
           $changed = $changed || $line ne $_;
       }
        finish_copy();
    }
}

sub handle_conf_py {
    $path = File::Spec->catfile(getcwd(), "doc", "source", "conf.py");
    if (not -e $path) {
        return;
    }

    start_copy();
    # assume only a single digit sub release
    my $version = substr($release, 0, -2);
    while( <$in> ) {
       $line = $_;
       my $old_line = $line;
       $line =~ s/(\d{4})\-(\d{4})/$1\-2023/i;
       if ($line =~ m/^version/i){
            $changed = index($line, $version) == -1;
            $line = "release = \'${version}\'\n";
       } elsif ($line =~ m/^release/i){
            $changed = index($line, $release) == -1;
            $line = "release = \'${release}\'\n";
       }
       print $out $line;
       # http://www.gnu.org/copyleft/gpl.html
    }
    finish_copy();
}

sub handle_version{
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

    if ($line !~ m/1\!7\.0\.0/i) {
        $changed = 1;

        while ($line !~ /\_\_version\_name\_\_/i){
            $line = <$in>;
            if (!defined $line){
                print("No __version_name__ line found\n");
                die $path;
            }
        }

        print $out "__version__ = \"1!7.0.0\"\n";
        print $out "__version_month__ = \"February\"\n";
        print $out "__version_year__ = \"2023\"\n";
        print $out "__version_day__ = \"TBD\"\n";
        print $out "__version_name__ = \"Revisionist\"\n";


        while( <$in> ) {
            print $out $_;
        }
    }
    finish_copy();
}

sub check_directory{
    my $start_path = getcwd();
    chdir $_[0];
    say "checking", getcwd();

    $repo = Git->repository();
    if ($release){
        my $info = $repo->command('branch');
        if (index($info, $release) == -1){
            $repo->command('branch', $release);
        }
        $repo->command('checkout', $release);
    }

    if ($release) {
        $path = File::Spec->catfile(getcwd(), "setup.py");
        handle_dependencies();
        $path = File::Spec->catfile(getcwd(), "requirements.txt");
        handle_dependencies();
        $path = File::Spec->catfile(getcwd(), "requirements-test.txt");
        handle_dependencies();
    }

    if ($main_repository) {
        handle_license();
        #handle_conf_py();
    }

    find(\&fix_each_file, getcwd());

    chdir $start_path;
}
$main_repository = 1;
check_directory("../JavaSpiNNaker");

#$release = "1!7.0.0";
$main_repository = 0;
check_directory("../SpiNNGym");
check_directory("../SpiNNaker_PDP2");
check_directory("../microcircuit_model");
check_directory("../MarkovChainMonteCarlo");
check_directory("../sPyNNaker8Jupyter");
$main_repository = 1;
check_directory("");
check_directory("../spinnaker_tools");
check_directory("../spinn_common");
check_directory("../SpiNNUtils");
check_directory("../SpiNNMachine");
check_directory("../SpiNNMan");
check_directory("../DataSpecification");
check_directory("../spalloc");
check_directory("../spalloc_server");
check_directory("../PACMAN");
check_directory("../SpiNNFrontEndCommon");
check_directory("../TestBase");
check_directory("../sPyNNaker");
check_directory("../SpiNNakerGraphFrontEnd");
check_directory("../PyNN8Examples");
check_directory("../IntroLab");
check_directory("../sPyNNaker8NewModelTemplate");
check_directory("../sPyNNakerVisualisers");
check_directory("../Visualiser");
check_directory("../IntegrationTests");
check_directory("../JavaSpiNNaker");
check_directory("../RemoteSpiNNaker");


