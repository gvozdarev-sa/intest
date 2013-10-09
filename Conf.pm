############################################################################################
# Copyright (C) 2013 Sergey Gvozdarev https://github.com/gvozdarev-sa/intest
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom
# the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
############################################################################################

package Conf;

require Exporter;
@ISA    = qw( Exporter );
@EXPORT = qw( %Conf);

###################################
use strict;
use File::Basename;

our %Conf =
(
    global_src          => "src",
    global_ws           => "ws",

    core_cfg            => "core_cfg",
    core_tests_file     => "tests.json",
    core_subtests_file  => "subtests.json",

    user_cfg            => "user_cfg",
    user_tests_file     => "tests.json",
    user_subtests_file  => "subtests.json",

    version             => "pre alpha",
    #logging
    log                 => "prime.log",
    debug               => 0,
    verbose             => 0,
    color               => 0,
    deep_log            => 0,
    html_log            => 0,
    #daemon
    daemon_host         => 'localhost',
    daemon_port         => 80,
    daemon_forks        => 3,
    daemon_req_per_fork => 10,
);


chomp( my $pwd = `pwd`);
$Conf{root} = $pwd;

1;
