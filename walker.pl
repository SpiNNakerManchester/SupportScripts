#!/usr/bin/perl
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
    '/support/',
    '/dist/',
    '\.egg-info/',
    '.coverage',
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
    'README.md'
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
    check_line('along with this program.  If not, see <http://www.gnu.org/licenses/>.(\s+)$');
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
   #  say "gnu: ", $path;
    start_copy();
    handle_top_lines();
    munch_existing_gnu();

    print $out "${prefix}\n";
    print $out "${prefix} Licensed under the Apache License, Version 2.0 (the \"License\");\n";
    print $out "${prefix} you may not use this file except in compliance with the License.\n";
    print $out "${prefix} You may obtain a copy of the License at\n";
    print $out "${prefix}\n";
    print $out "${prefix}     http://www.apache.org/licenses/LICENSE-2.0\n";
    print $out "${prefix}\n";
    print $out "${prefix} Unless required by applicable law or agreed to in writing, software\n";
    print $out "${prefix} distributed under the License is distributed on an \"AS IS\" BASIS,\n";
    print $out "${prefix} WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n";
    print $out "${prefix} See the License for the specific language governing permissions and\n";
    print $out "${prefix} limitations under the License.\n";
    while( <$in> ) {
        print $out $_;
    }
    $changed = 1; # Perl has bool so using 1 for value
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
    if ($path =~ /LICENSE/){
        return;
    }
    if ($path =~ /\.bak$/){
        return;
    }

    # ignore all but version files
    if ($path =~ m/\/\_version\.py$/){
        handle_version();
        return;
    }

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
    unlink $path;
    my $s_l_path = File::Spec->catfile(dirname(getcwd()), "SupportScripts", "LICENSE");
    copy($s_l_path, $path) or die "LICENSE copy failed: $!";
    return

    $path = File::Spec->catfile(getcwd(), "LICENSE.md");
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
    while ($line !~ /\_version/i){
        print $out $line;
        $line = <$in>;
        if (!defined $line){
            print("No __version line found\n");
            die $path;
        }
    }

    $changed = index($line, $release) == -1;
    print $out "__version__ = \"${release}\"\n";
    print $out "__version_month__ = \"February\"\n";
    print $out "__version_year__ = \"2023\"\n";
    print $out "__version_day__ = \"TBD\"\n";
    print $out "__version_name__ = \"Revisionist\"\n";

    # assuming here there are no weird lines below
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

    $path = File::Spec->catfile(getcwd(), "setup.py");
    handle_dependencies();
    $path = File::Spec->catfile(getcwd(), "requirements.txt");
    handle_dependencies();
    $path = File::Spec->catfile(getcwd(), "requirements-test.txt");
    handle_dependencies();

    if ($main_repository) {
        handle_license();
        handle_conf_py();
    }

    find(\&fix_each_file, getcwd());

    chdir $start_path;
}

$release = "1!7.0.0";
$main_repository = 0;
check_directory("../SpiNNGym");
#die "done";
check_directory("../SpiNNaker_PDP2");
check_directory("../microcircuit_model");
check_directory("../MarkovChainMonteCarlo");
check_directory("../sPyNNaker8Jupyter");
$main_repository = 1;
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
