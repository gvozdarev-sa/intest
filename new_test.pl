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

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";


use Utils;
use Conf;

sub main
{
    $Conf{verbose} = 1;
    my $r_tests = &LoadJSON( "$Conf{user_cfg}/$Conf{user_tests_file}");
    print &DumpJSON( $r_tests);
    if ( !$r_tests && ref $r_tests ne 'HASH' && !$r_tests->{tests} && ref $r_tests->{tests} ne 'ARRAY')
    {
        $r_tests = { tests => [ ]};
    }
    my %h_tests;
    map { $h_tests{ $_} = 1; } @{ $r_tests->{tests}};

    my $name;
    my $exist = 1;
    while ( $exist)
    {
        print "Task name\n";
        chomp( $name = <>);
        if ( $h_tests{ $name} || $h_tests{ "$name/$name"})
        {
            print "Such name allready exist\n";
        }
        else
        {
            $exist = 0;
        }
    }
    # ===
    my %include = ();
    my @ids = ();
    my $next = 1;
    my $i = 0;
    while ( $next)
    {
        my $opts = {};
        print "Subtest core_run_compare $i\n";

        print "ARGV (default: '')\n";
        chomp( $opts->{ARGV} = <>);

        print "STDIN (default: '')\n";
        chomp( $opts->{STDIN} = <>);

        print "STDOUT regex (default: '')\n";
        chomp( $opts->{STDOUT}{must} = <>);
        $opts->{STDOUT}{type} = 'regex';

        print "STDERR (default: '')\n";
        chomp( $opts->{STDERR}{must} = <>);
        $opts->{STDERR}{type} = 'regex';

        print "return code (default: '0')\n";
        chomp( $opts->{CODE}{must} = <>);
        $opts->{CODE}{type} = 'int_eq';
        if ( $opts->{CODE}{must} eq '')
        {
            $opts->{CODE}{must} = 0;
        }

        print "Yet another subtest? ( Yes/No)\n";
        chomp ( my $t = <>);
        if ( $t !~ /Yes|yes|y|YES|Y/)
        {
            $next = 0;
        }
        $include{ $i}{opts} = $opts;
        $include{ $i}{type} = 'subtest';
        $include{ $i}{name} = 'core_run_compare';

        push @ids, $i;
        $i++;
    }
    &Execute( "mkdir -p $Conf{user_cfg}/tests/$name");
    &Execute( "cp -rf $Conf{user_cfg}/tests/task0/* $Conf{user_cfg}/tests/$name");
    &Execute( "mv $Conf{user_cfg}/tests/$name/task0.json $Conf{user_cfg}/tests/$name/$name.json");
    &Execute( "mv $Conf{user_cfg}/tests/$name/task0_container.json $Conf{user_cfg}/tests/$name/${name}_container.json");

    my $task = &LoadJSON( "$Conf{user_cfg}/tests/$name/$name.json");
    $task->{include}{5}{name} = "${name}_container";
    &DumpJSON( $task, "$Conf{user_cfg}/tests/$name/$name.json");

    my $task_cont = &LoadJSON( "$Conf{user_cfg}/tests/$name/${name}_container.json");
    $task_cont->{name} = "${name}_container";
    $task_cont->{pass_if}{done}{ids} = \@ids;
    $task_cont->{done_if}{done}{ids} = \@ids;
    $task_cont->{percentage}{ids} = \@ids;
    $task_cont->{include} = \%include;
    &DumpJSON( $task_cont, "$Conf{user_cfg}/tests/$name/${name}_container.json");

    push @{ $r_tests->{tests}}, "$name/$name.json";
    push @{ $r_tests->{tests}}, "$name/${name}_container.json";

    &DumpJSON( $r_tests, "$Conf{user_cfg}/$Conf{user_tests_file}");
}








&main( );
