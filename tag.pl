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

# This converts existing branches on github into tags
# Hard to repeat. Requires tags to be deleted and branches recreated

use strict;
use warnings;
use Cwd qw(getcwd);
use feature qw(say);
use Git;


my $release = "7.3.0";  # Without the leadint 1!

sub git_tag{
    my $start_path = getcwd();
    chdir $_[0];
    say "checking ", getcwd();

    my $repo = Git->repository();

    # find remote branch
    my $info = $repo->command('ls-remote', '--heads', 'origin');
    if (index($info, $release) > -1){
        say "tagging";
        $repo->command('push', "origin", "origin/${release}:refs/tags/${release}");
        $repo->command('push', "origin", ":refs/heads/${release}");
    }
    chdir $start_path;
}

git_tag("../my_spinnaker");
git_tag("../spinnaker_tools");
git_tag("../spinn_common");
git_tag("../SpiNNUtils");
git_tag("../SpiNNMachine");
git_tag("../SpiNNMan");
git_tag("../spalloc");
git_tag("../PACMAN");
git_tag("../SpiNNFrontEndCommon");
git_tag("../TestBase");
git_tag("../sPyNNaker");
git_tag("../SpiNNakerGraphFrontEnd");
git_tag("../PyNNExamples");
git_tag("../sPyNNakerNewModelTemplate");
git_tag("../sPyNNakerVisualisers");
git_tag("../Visualiser");
git_tag("../JavaSpiNNaker");
git_tag("../SpiNNGym");
git_tag("../SpiNNaker_PDP2");
git_tag("../microcircuit_model");
git_tag("../MarkovChainMonteCarlo");
git_tag("../sPyNNakerJupyter");
git_tag("../sphinx8");
git_tag("../IntegrationTests");
git_tag("../TSPonSpiNNaker");
git_tag("../BitBrainDemo");
# die "stop";

