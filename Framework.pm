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

use File::Basename;

use Utils;
use Conf;
use State;
use Errors;

###
sub CdRoot
{
    &Print( "cd to root dir $Conf{root}", 0);
    chdir $Conf{root};
}
sub CdWs
{
    my $ws = &GetWs( );
    &Utils::Print( "cd to ws dir $ws", 0);
    chdir "$ws";
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

    my $driver_basename = basename( $Conf{subtests}{ $subtest_name}{driver});
    my $driver_fullname = $Conf{subtests}{ $subtest_name}{driver};
    local $@;
    eval
    {
        require "$driver_fullname.pm";
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
    my $run = '$subtest_res = ' . $driver_basename . '::Run( $r_opts, \\%Conf);';
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
    my $test_name      = shift;
    my $r_test_opts    = shift;
    ###
    my $r_test_res = &BlankRes( );
    ###
    my @subtests = ();

    # go deeper
    &State::PushDeep( );
    &Print( "=" x ( 80 - 4 * &State::GetDeep( )) . "\n*Run test $test_name\n" . "-" x ( 80 - 4 * &State::GetDeep( )));

    # Sort test by id
    my @sorted_ids = sort { $Conf{tests}{ $test_name}{include}{ $a} <=> $Conf{tests}{ $test_name}{include}{ $b}} keys %{ $Conf{tests}{ $test_name}{include}};

    # global opts = default_opts in JSON + opts from command line
    $r_test_opts = &MergeOpts( $Conf{tests}{ $test_name}{default_opts} || {}, $r_test_opts);

    # Run tests/subtest one by one with checking deps
    foreach my $id ( @sorted_ids)
    {
        my $r_chk_res;
        $r_chk_res = &CheckDeps( $r_test_res, $test_name, $id);

        if ( $r_chk_res->{code} == $PASS)
        {
            # cd to root
            &CdRoot( );

            # test for special id  = options in json + global opts
            my $r_id_opts = &MergeOpts(  $Conf{tests}{ $test_name}{include}{ $id}{opts}, $r_test_opts);
            $r_test_res->{items_res}{ $id} = &RunItemById( $id, $test_name, $r_id_opts, $r_test_res);
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
    $Conf{tests}      = &LoadTests   ( "$Conf{core_cfg}/$Conf{core_tests_file}",    $Conf{core_cfg});
    $Conf{subtests}   = &LoadSubtests( "$Conf{core_cfg}/$Conf{core_subtests_file}", $Conf{core_cfg});

    my $user_tests    = "$Conf{user_cfg}/$Conf{user_tests_file}";
    my $user_subtests = "$Conf{user_cfg}/$Conf{user_subtests_file}";
    if ( -f $user_tests)
    {
        $Conf{tests}    = &MergeOpts( &LoadTests   ( $user_tests   , $Conf{user_cfg}), $Conf{tests});
    }
    if ( -f $user_subtests)
    {
        $Conf{subtests} = &MergeOpts( &LoadSubtests( $user_subtests, $Conf{user_cfg}), $Conf{subtests});
    }
}

sub LoadTest($$)
{
    my $test_name = shift;
    my $cfg_dir   = shift;
    ###
    return &LoadJSON( "$cfg_dir/tests/$test_name.json");
}

sub LoadSubtest($$)
{
    my $subtest_name = shift;
    my $cfg_dir      = shift;
    ###
    my $subtest = &LoadJSON( "$cfg_dir/subtests/$subtest_name.json");
    $subtest->{driver} = "$cfg_dir/subtests/drivers/$subtest->{driver}";

    return $subtest;
}

sub LoadTests($$)
{
    my $tests_file = shift;
    my $cfg_dir    = shift;
    ###

    &Print( "Load tests: $tests_file", 1);
    my $r_tests_list = &LoadJSON( $tests_file);

    my $tests = {};
    foreach my $test_file ( @{ $r_tests_list->{tests}})
    {
        &Print( "  loading $test_file");
        my $test = &LoadTest( $test_file, $cfg_dir);

        $tests->{ $test->{name}}          = $test;
        $tests->{ $test->{name}}{cfg_dir} = "$cfg_dir/$test_file";
    }

    return $tests;
}

sub LoadSubtests($$)
{
    my $subtests_file = shift;
    my $cfg_dir       = shift;
    ###

    &Print( "Load subtests: $subtests_file", 1);
    my $r_subtests_list = &LoadJSON( $subtests_file);

    my $sub_tests = {};
    foreach my $subtest_name ( @{ $r_subtests_list->{subtests}})
    {
        &Print( "  loading $subtest_name");
        $sub_tests->{ $subtest_name} = &LoadSubtest( $subtest_name, $cfg_dir);
    }

    return $sub_tests;
}

sub GetVersion
{
    return $Conf{version};
}

1;
