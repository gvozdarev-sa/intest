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

package Framework;

require Exporter;
@ISA    = qw( Exporter );
@EXPORT =
qw(
    InitConf
    GetVersion
    CdWs
    CdRoot);

#####################################
use strict;

use FindBin;
use lib "$FindBin::Bin";

use Utils;
use Conf;
use Errors;


sub CdRoot
{
    &Print( "cd to root dir $Conf{root}", 0);
    chdir $Conf{root};
}
sub CdWs
{
    &Print( "cd to ws dir $Conf{root}/$Conf{ws}", 0);
    chdir "$Conf{root}/$Conf{ws}";
}

sub RunSubtest
{
    my $subtest_name    = shift;
    my $r_opts          = shift;
    ###
    my $r_res = {};

    if ( ! $Conf{subtests}{ $subtest_name})
    {
        $r_res->{code}  = $BADTEST;
        $r_res->{done}  = 0;
        $subtest_name   = $subtest_name || "subtest_name - undef";
        $r_res->{msg}   = "ERROR: subtest $subtest_name doesn'y exist in conf";
        return $r_res;
    }

    local $@;
    eval
    {
        require "$Conf{subtests}{ $subtest_name}{driver}.pm";
    };
    if ( $@)
    {
        $r_res->{code} = $BADTEST;
        $r_res->{done} = 0;
        $r_res->{msg}  = "ERROR: can't load $subtest_name driver ( $@)";
        &Print( $r_res->{msg});
        return $r_res;
    }

    # merge opts
    $r_opts = &MergeOpts( $Conf{subtests}{ $subtest_name}{default_opts} || {}, $r_opts);

    my $subtest_res;
    my $run = '$subtest_res = ' . $Conf{subtests}{ $subtest_name}{driver} . '::Run( $r_opts, \\%Conf);';
    &Print( $run, 0);

    local $@;
    eval $run;
    if ( $@)
    {
        $r_res->{code} = $RUNFAIL;
        $r_res->{done} = 0;
        $r_res->{msg}  = "ERROR: runtime error - ( $@)";
        &Print( $r_res->{msg});
    }
    else
    {
        if ( ref $subtest_res eq 'HASH')
        {
            $r_res->{code} = $subtest_res->{code};
            $r_res->{done} = 1;
            $r_res->{msg}  = "DONE: with code - $r_res->{code}\n";
            $r_res->{msg} .= "$subtest_res->{msg}";

            $r_res->{res}  = $subtest_res;
        }
        else
        {
            $r_res->{code} = $subtest_res;
            $r_res->{done} = 1;
            $r_res->{msg}  = "DONE: with code - $subtest_res\n";
        }
        &Print( $r_res->{msg}, 0);
    }

    my $line = sprintf( "subtest: %-30s: ", $subtest_name ) . &Utils::GetShortReport( $r_res);

    if ( &IsPassed( $r_res ))
    {
        &PrintPassed( $line);
    }
    else
    {
        &PrintError( $line);
    }
    return $r_res;
}


sub PrepareSubtest
{
    my $subtest_name = shift;
    my $r_opts       = shift;


}

sub RunItemById
{
    my $id         = shift;
    my $test_name  = shift;
    my $r_opts     = shift;
    my $r_test_res = shift;
    ###
    my $r_res = &BlankRes( );
    ###

    if ( $Conf{tests}{ $test_name}{include}{ $id})
    {
        my $r = $Conf{tests}{ $test_name}{include}{ $id};

        if     ( $r->{type} eq 'test')
        {
            $r_res = &RunTest( $r->{name}, $r_opts, $r_test_res);
        }
        elsif ( $r->{type} eq 'subtest')
        {
            $r_res = &RunSubtest( $r->{name}, $r_opts, $r_test_res);
        }
        else
        {
            $r_res->{code} = $BADTEST;
            $r_res->{msg}  = "ERROR : unknown item type ( $r->{type})";
        }
    }
    else
    {
        $r_res->{code} = $BADTEST;
        $r_res->{msg}  = "ERROR : id ( $id) doesn't exist in test( $test_name)";
    }

    return $r_res;
}


sub RunTest
{
    my $test_name = shift;
    my $r_opts    = shift;
    ###
    my $r_test_res = &BlankRes( );
    ###
    my @subtests = ();

    # go deeper
    &State::PushDeep( );
    &Print( "=" x ( 80 - 4 * &State::GetDeep( )) . "\n*Run test $test_name\n" . "-" x ( 80 - 4 * &State::GetDeep( )));

    # Sort test by id
    my @sorted_ids = sort { $Conf{tests}{ $test_name}{include}{ $a} <=> $Conf{tests}{ $test_name}{include}{ $b}} keys %{ $Conf{tests}{ $test_name}{include}};

    # merge opts
    $r_opts = &MergeOpts( $Conf{tests}{ $test_name}{default_opts} || {}, $r_opts);


    # Run tests/subtest one by one with checking deps
    foreach my $id ( @sorted_ids)
    {
        my $r_chk_res;
        $r_chk_res = &CheckDeps( $r_test_res, $test_name, $id);

        if ( $r_chk_res->{code} == $PASS)
        {
            # cd to root
            &CdRoot( );

            $r_test_res->{items_res}{ $id} = &RunItemById( $id, $test_name, $Conf{tests}{ $test_name}{include}{ $id}{opts}, $r_test_res);
        }
        else
        {
            $r_test_res->{items_res}{ $id} = &BlankRes( );
            $r_test_res->{items_res}{ $id}{code} = $DEPFAIL;
            $r_test_res->{items_res}{ $id}{msg}  = $r_chk_res->{msg};
        }
    }
    # Check results
    &CheckResults( $test_name, $r_test_res);



    my $line = sprintf( "test   : %-30s: ", $test_name ) . &Utils::GetShortReport( $r_test_res);
    if ( &IsPassed( $r_test_res ))
    {
        &PrintPassed( $line);
    }
    else
    {
        &PrintError( $line);
    }
    &Print( "-" x ( 80 - 4 * &State::GetDeep( )) . "\n*Finish test $test_name\n" . "=" x ( 80 - 4 * &State::GetDeep( )));
    &State::PopDeep( );
    return $r_test_res;
}

sub CheckResults
{
    my $test_name   = shift;
    my $r_test_res  = shift;
    ###
    $r_test_res->{msg} = '';

    if   ( $Conf{tests}{ $test_name}{percentage})
    {
        $r_test_res->{percentage} = &CalcPercentage(
                                                        $Conf{tests}{ $test_name}{percentage}{type},
                                                        $Conf{tests}{ $test_name}{percentage}{ids},
                                                        $r_test_res
                                                    );

    }

    if   (  $Conf{tests}{ $test_name}{pass_if})
    {
        my $cond = $Conf{tests}{ $test_name}{pass_if};

        my $r_chk_res = &CheckHelper( $cond, $r_test_res);
        if ( $r_chk_res->{code} == $PASS)
        {
            $r_test_res->{code} = $PASS;
        }
        else
        {
            $r_test_res->{code}  = $FAIL;
            $r_test_res->{msg}  .= $r_chk_res->{msg};
        }
    }
    else
    {
        $r_test_res->{code}  = $BADTEST;
        $r_test_res->{msg}  .= "ERROR : test ( $test_name) doesn't contain pass condition\n";
    }

    if   (  $Conf{tests}{ $test_name}{done_if})
    {
        my $cond = $Conf{tests}{ $test_name}{done_if};
        my $r_chk_res = &CheckHelper( $cond, $r_test_res);

        if ( $r_chk_res->{code} == $PASS)
        {

            $r_test_res->{done} = 1;
        }
        else
        {
            $r_test_res->{done}  = 0;
            $r_test_res->{msg}  .= $r_chk_res->{msg};
        }
    }
    else
    {
        $r_test_res->{code}  = $BADTEST;
        $r_test_res->{msg}  .= "ERROR : test ( $test_name) doesn't contain done condition\n";
    }
}



sub CheckDeps
{
    my $r_test_res      = shift;
    my $test_name       = shift;
    my $id              = shift;
    ###
    my $r_res = &BlankRes;
    $r_res->{code} = $PASS;
    $r_res->{msg}  = '';
    ###

    my $check_res = &CheckHelper( $Conf{tests}{ $test_name}{include}{ $id}{depend_on}, $r_test_res) if ( defined $Conf{tests}{ $test_name}{include}{ $id}{depend_on});
    if ( $check_res->{code} != $PASS)
    {
        $r_res->{code} = $DEPFAIL;
        $r_res->{msg}  = $check_res->{msg};
    }

    return $r_res;
}


sub InitConf
{
    $Conf{tests}      = &LoadTests   ( $Conf{tests_file});
    $Conf{subtests}   = &LoadSubtests( $Conf{subtests_file});
}

sub LoadTest
{
    my $test_name = shift;

    return &LoadJSON( "config/tests/$test_name.json"); # FIXME
}

sub LoadSubtest
{
    my $subtest_name = shift;

    return &LoadJSON( "config/subtests/$subtest_name.json"); # FIXME
}

sub LoadTests
{
    my $tests_file = shift;

    &Print( "Load tests: $tests_file", 1);
    my $r_tests_list = &LoadJSON( $tests_file);

    my $tests = {};
    foreach my $test_name ( @{ $r_tests_list->{tests}})
    {
        &Print( "  loading $test_name");
        $tests->{ $test_name} = &LoadTest( $test_name);
    }

    return $tests;
}

sub LoadSubtests
{
    my $subtests_file = shift;

    &Print( "Load subtests: $subtests_file", 1);
    my $r_subtests_list = &LoadJSON( $subtests_file);

    my $sub_tests = {};
    foreach my $subtest_name ( @{ $r_subtests_list->{subtests}})
    {
        &Print( "  loading $subtest_name");
        $sub_tests->{ $subtest_name} = &LoadSubtest( $subtest_name);
    }

    return $sub_tests;
}

sub GetVersion
{
    return $Conf{version};
}

1;
