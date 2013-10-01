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

package Utils;

require Exporter;
@ISA    = qw( Exporter );
@EXPORT = qw(
Print
Execute
DumpHash
Assert

LoadJSON

MergeOpts

CheckHelper
CheckByType
CalcPercentage

BlankRes
);

###################################################
use strict;

use Capture::Tiny 'capture';
use Data::Dumper qw( Dumper);
use JSON;

use Errors;
use Conf;
use State;

sub BlankRes
{
    my $r_res = {};
    $r_res->{code}      = $BADTEST;
    $r_res->{msg}       = "ERROR : res - undefined ( don't filed by test/subtest)";
    $r_res->{done}      = 0;
    $r_res->{percentage}= 0;

    return $r_res;
}
# ---
sub IsDone
{
    my $r_res = shift;
    ###
    return ( $r_res->{done}) ? ( 1) : ( 0);
}

sub SetDone
{
    my $r_res = shift;
    my $done  = shift || 1;
    ###
    $r_res->{done} = $done;
}
# ---

sub IsPassed
{
    my $r_res = shift;
    ###
    return ( $r_res->{code} == $PASS) ? ( 1) : ( 0);
}
sub IsFailed
{
    my $r_res = shift;
    ###
    return ( $r_res->{code} == $PASS) ? ( 0) : ( 1);
}

sub SetCode
{
    my $r_res = shift;
    my $code  = shift;
    ###
    $r_res->{code} = $code;
}

sub GetStrCode
{
    my $r_res = shift;
    ###
    if ( $Errors::str_errors->{ $r_res->{code}})
    {
        return $Errors::str_errors->{ $r_res->{code}};
    }
    else
    {
        return "UNDEFCODE";
    }
}

sub GetPercentage
{
    my $r_res    = shift;
    ###
    return $r_res->{percentage};
}

sub SetPercentage
{
    my $r_res    = shift;
    my $percentage = shift;
    ###
    $r_res->{percentage} = $percentage;
}

sub GetShortReport
{
    my $r_res = shift;
    ###
    my $str = '';
    if ( &IsDone( $r_res))
    {
        $str .= sprintf( "%-8s:", "Done 1");
    }
    else
    {
        $str .= sprintf( "%-8s:", "Done 0");
    }

    if ( &IsPassed( $r_res))
    {
        $str .= sprintf( "%-25s:", "passed");
    }
    else
    {
        $str .= sprintf( "%-25s:", "failed ( ".&GetStrCode( $r_res) . " )");
    }

    $str .= sprintf( "percentage: %02d:", &GetPercentage( $r_res));
#    $str .= "\n";

    return $str;
}
# ---


sub Execute
{
    my $cmd = shift;
    my %res;

    &Print( "Execute : $cmd", 0);
    ( my $stdout, my $stderr, my $return) = capture  { system( $cmd)} ;

    $res{stdout} = $stdout;
    $res{stderr} = $stderr;
    $res{code}   = $return;

    if ( $res{code} != $PASS)
    {
        &Print( "  return code $res{code}\n    with stdout:\n$res{stdout}\n    with stderr:\n$res{stderr}", 1);
    }

    return \%res;
}

sub CheckHelper
{
    my $cond         = shift;
    my $r_test_res   = shift;
    ###
    my $r_res = &BlankRes( );
    $r_res->{msg} = '';
    ###
    my $OK = 1;

    foreach my $subcond ( keys %$cond)
    {
        foreach my $id ( @{ $cond->{ $subcond}{ids}})
        {
            #check self result
            if ( $id != -1)
            {
                if ( defined $r_test_res->{items_res}{ $id}{ $subcond})
                {
                    if ( !&CheckByType( $cond->{ $subcond}->{type}, $r_test_res->{items_res}{ $id}{ $subcond}, $cond->{ $subcond}{must}))
                    {
                        $r_res->{msg} .= "CHECKS FAILED: " . &DumpHash( $cond->{ $subcond});
                        $OK &&= 0;
                    }
                }
                else
                {
                    $r_res->{msg} .= "CHECK FAILED: subcond( $subcond ) - undef in tests results\n";
                    $OK &&= 0;
                }
            }
            else
            {
                if ( defined $r_test_res->{ $subcond})
                {
                    if ( !&CheckByType( $cond->{ $subcond}->{type}, $r_test_res->{ $subcond}, $cond->{ $subcond}{must}))
                    {
                        $r_res->{msg} .= "CHECKS FAILED: " . &DumpHash( $cond->{ $subcond});
                        $OK &&= 0;
                    }
                }
                else
                {
                    $r_res->{msg} .= "CHECK FAILED: subcond( $subcond ) - undef in tests results\n";
                    $OK &&= 0;
                }

            }
        }
    }
    if ( $OK)
    {
        $r_res->{code} = $PASS;
    }
    else
    {
        $r_res->{code} = $FAIL;
    }
    return $r_res;
}

sub CheckByType
{
    my $type = shift;
    my $item = shift;
    my $must = shift;

    if    ( $type eq 'bool')
    {
        return 1 if ( $item == $must);
    }
    elsif ( $type eq 'code')
    {
        my $res;
        local $@;
        my $cmd = "\$res = $item == $must";
        eval $cmd;
        print "$cmd; : $@" if $@;
        return 1 if ( $res)
    }
    elsif ( $type eq 'int_eq')
    {
        return 1 if ( $item == $must);
    }
    elsif ( $type eq 'int_gr')
    {
        return 1 if ( $item > $must);
    }
    elsif ( $type eq 'int_ls')
    {
        return 1 if ( $item < $must);
    }
    elsif ( $type eq 'int_greq')
    {
        return 1 if ( $item >= $must);
    }
    elsif ( $type eq 'int_lseq')
    {
        return 1 if ( $item <= $must);
    }
    elsif ( $type eq 'str_eq')
    {
        return 1 if ( $item eq $must);
    }
    elsif ( $type eq 'str_gr')
    {
        return 1 if ( ( $item cmp $must) == 1);
    }
    elsif ( $type eq 'str_ls')
    {
        return 1 if ( ( $item cmp $must) == -1);
    }
    elsif ( $type eq 'str_ne')
    {
        return 1 if ( $item ne $must);
    }
    elsif ( $type eq 'regex')
    {
        return 1 if ( $item =~ $must);
    }

    return 0;
}

sub CalcPercentage
{
    my $type       = shift;
    my $r_ids      = shift;
    my $r_test_res = shift;
    ###
    my $res = 0;
    ###
    if   ( $type eq 'copy')
    {
        $res = $r_test_res->{items_res}{ $r_ids->[ 0]}{percentage};
    }
    else
    {
        my $passed = 0;
        my $failed = 0;

        foreach my $id ( @$r_ids)
        {
            if ( $r_test_res->{items_res}{ $id}{code} == $PASS)
            {
                $passed++;
            }
            else
            {
                $failed++;
            }
        }
        if ( $passed + $failed)
        {
            $res =  100 * $passed / ( $passed + $failed);
        }
        else
        {
            $res = 0;
        }

    }

    return $res;
}

sub Assert
{
    my $check = shift;
    my $msg   = shift || "assert msg - undef";
    if ( !$check)
    {
        &Print( $msg);
        die $msg;
    }
}

sub MergeOpts
{
    my $r_default_opts = shift;
    my $r_opts         = shift;
    ###
    my $r = $r_default_opts;
    ##
    foreach my $opt ( keys %$r_opts)
    {
        $r->{ $opt} = $r_opts->{ $opt};
    }

    return $r;
}


sub LoadJSON
{
    my $json_file = shift;

    open FF, "< $json_file";
    my @json = <FF>;
    close FF;

    &Print( "LoadJSON file - $json_file", 0);
    my $perl_hash = &decode_json( join( "", @json));


    return $perl_hash;
}


sub Print
{
    my $msg     = shift;
    my $verbose = shift;

    my @msgs = split( "\n", $msg);

    if ( scalar @msgs > 1)
    {
        foreach my $sub_msg ( @msgs)
        {
            &Print( $sub_msg, $verbose);
        }
        return;
    }

    $verbose = 1 if ( ! defined $verbose || $Conf{verbose});

    ( my $sec, my $min,my $hour, my $mday, my $mon, my $year, my $wday, my $yday, my $isdst) = localtime( time);
    my $timestamp;
    $timestamp = sprintf( "[ %02d-%02d:%02d:%02d ] ", $mday, $hour, $min, $sec);
    $timestamp = "\x1b[1;34m" . $timestamp . "\x1b[0m" if ( $Conf{color});

    my $caller;
    $caller = ( caller( 1))[ 3];
    $caller = sprintf( "%-33s", $caller);
    $caller =  "\x1b[1;36m" . $caller . "\x1b[0m" if ( $Conf{color});

    my $prefix = '';
    $prefix .= $timestamp;
    $prefix .= " $caller : " if ( $Conf{debug});
    if ( $Conf{deep_log})
    {
        $prefix .= '---|' x &State::GetDeep( );
    }
    else
    {
        $prefix .= &State::GetDeep( );
    }
    $prefix .= '> ';

    $msg = $prefix . $msg . "\n";

    print( $msg) if $verbose;

    if ( $Conf{log} && open LOG, ">> $Conf{log}")
    {
        print LOG $msg;
        close LOG;
    }
    if( $Conf{test_log} && open LOG, ">> $Conf{test_log}")
    {
        print LOG $msg;
        close LOG;
    }
}

sub DumpHash
{
    my $r = shift;

    local $Data::Dumper::Terse = 1;
    return &Dumper( $r);
}

1;

