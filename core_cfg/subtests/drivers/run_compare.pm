package run_compare;
use strict;

BEGIN
{
    use File::Basename;
    my $dir = dirname dirname dirname dirname $0;
    push @INC, $dir;
}

use Utils;
use Errors;
use Framework qw ( CdWs);

sub Run
{
    my $r_opts      = shift;
    my $r_conf      = shift;
    my $r_tests_res = shift;
    ###
    my $r_res = &BlankRes;
    ###
    &CdWs( );

    my $stdin_cmd;
    if ( $r_opts->{STDIN})
    {
        $stdin_cmd = "echo \'$r_opts->{STDIN}\' | ";
    }
    elsif( $r_opts->{STDIN_FILE})
    {
        $stdin_cmd = "cat \'$r_opts->{STDIN_FILE}\' | ";
    }
    else
    {
        $stdin_cmd = "";
    }
    my $cmd = $stdin_cmd . "$r_opts->{bin} $r_opts->{ARGV}";

    my $run_res = &Execute( $cmd);

    if ( !&CheckByType( $r_opts->{CODE}{type}, $run_res->{code}, $r_opts->{CODE}{must}))
    {
        $r_res->{code} = $RUNFAIL;
        $r_res->{done} = 1;
        $r_res->{msg}  = "RUN FAIL :\ncode: $run_res->{code}\nstderr: $run_res->{stderr}\n";
    }
    elsif ( !&CheckByType( $r_opts->{STDOUT}{type}, $run_res->{stdout}, $r_opts->{STDOUT}{must}))
    {
        $r_res->{code} = $CMPFAIL;
        $r_res->{done} = 1;
        $r_res->{msg}  = "COMPARE FAIL :\nstdout: $run_res->{stdout}";
    }
    elsif ( !&CheckByType( $r_opts->{STDERR}{type}, $run_res->{stderr}, $r_opts->{STDERR}{must}))
    {
        $r_res->{code} = $CMPFAIL;
        $r_res->{done} = 1;
        $r_res->{msg}  = "COMPARE FAIL :\nstderr: $run_res->{stderr}\n";
    }
    else
    {
        $r_res->{code} = $PASS;
        $r_res->{done} = 1;
        $r_res->{msg}  = "";
    }


    return $r_res;
}


1;
