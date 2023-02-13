#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);
use Cwd qw(getcwd);
use File::Find qw(find);
use File::Basename;
use File::Spec;
use File::Copy;

my @ignore_dirs = (
    '/.git/',
    '/.idea/',
    '/doc/build/',
    '/support/',
    '/dist/',
    '\.egg-info/',
    '.coverage',
    '\.ratexclude',
    'project$',
    '.travis.yml$',
    '/modified_src/',
    '/.settings/',
    'cache/',
    '/MANIFEST.in$',
    '/pypi_to_import$',
     );

my $path;
my $line;
my $new_path;
my $permissions;
my $prefix;
my $in;
my $out;

sub fix_top_line{
    $line =~ s/copyright(.*)(\d{4})(.*)(\d{4})(.*)the university of manchester/Copyright (c) $2-2023 The University of Manchester/i;
    $line =~ s/copyright(\D*)(\d{4})(\D*)the university of manchester/Copyright (c) $2-2023 The University of Manchester/i;
    #$line =~ s/copyright(.*)(\d{4})(\D*)the university of manchester$/Copyright $2-2023 The University of Manchester/i;
    $line =~ s/(.*) 2023-2023(.*)/$1 2023$2/i;
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
    check_line('Copyright \(c\) (\d{4}-)?2023 The University of Manchester(\s)$');
    print $out $line;
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
    $permissions = (stat $path)[2] & 00777;
    $new_path = "${path}.bak";
    open $in,  '<', $path     or die "Can't read old file: $path";
    open $out, '>', $new_path or die "Can't write new file: $new_path";
}

sub finish_copy{
    close $in;
    close $out;
    unlink $path;
    rename $new_path, $path;
    chmod $permissions, $path;
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
    finish_copy();
}

sub handle_apache_file {
    # say "gnu: ", $path;
    start_copy();

    handle_top_lines();
    while( <$in> ) {
        print $out $_;
    }
    finish_copy();
}

sub fix_copyrights{
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

    open(FILE, $path) or die "Can't open: $path!\n";
    if (grep{/GNU General Public License/} <FILE>){
       handle_gnu_file();
    }
    # warning can not grep the same open file twice!
    open(FILE, $path) or die "Can't open: $path!\n";
    if (grep{/Apache License/} <FILE>){
       handle_apache_file();
   }
}

sub handle_setup {
    $path = File::Spec->catfile(getcwd(), "setup.py");
    #say $path;
    if (not -e $path) {
        return;
    }
    start_copy();
    $permissions = (stat $path)[2] & 00777;
    $new_path = "${path}.bak";
    #say "setup: ", $new_path;
    open $in,  '<', $path     or die "Can't read old file: $path";
    open $out, '>', $new_path or die "Can't write new file: $new_path";
    while( <$in> ) {
       $line = $_;
       $line =~ s/GNU General Public License v3 \(GPLv3\)/Apache License 2.0/i;
       $line =~ s/GNU GPLv3.0/Apache License 2.0/i;
       print $out $line;
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
   }
    finish_copy();
}

sub check_directory{
    my $start_path = getcwd();
    chdir $_[0];
    say "checking", getcwd();

    handle_setup();
    handle_license();
    find (\&fix_copyrights, getcwd());

    chdir $start_path;
}

check_directory("../spinnaker_tools");
#check_directory("../spinn_common");
#check_directory("../SpiNNUtils");
#check_directory("../SpiNNMachine");
#check_directory("../SpiNNMan");
#check_directory("../DataSpecification");
#check_directory("../spalloc");
#check_directory("../spalloc_server");
#check_directory("../PACMAN");
#check_directory("../SpiNNFrontEndCommon");
#check_directory("../TestBase");
#check_directory("../sPyNNaker");
#check_directory("../SpiNNakerGraphFrontEnd");
#check_directory("../PyNN8Examples");
#check_directory("../IntroLab");
#check_directory("../sPyNNaker8NewModelTemplate");
#check_directory("../sPyNNakerVisualisers");
#check_directory("../Visualiser");
#check_directory("../IntegrationTests");
