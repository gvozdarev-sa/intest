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

    my $cmd = "$r_opts->{bin} $r_opts->{FLAGS}";

    my $run_res = &Execute( $cmd);

    if ( !&CheckByType( $r_opts->{code}{type}, $run_res->{code}, $r_opts->{code}{must}))
    {
        $r_res->{code} = $RUNFAIL;
        $r_res->{done} = 1;
        $r_res->{msg}  = "RUN FAIL :\ncode: $run_res->{code}\nstderr: $run_res->{stderr}\n";
    }
    elsif ( !&CheckByType( $r_opts->{code}{type}, $run_res->{stdout}, $r_opts->{stdout}{must}))
    {
        $r_res->{code} = $CMPFAIL;
        $r_res->{done} = 1;
        $r_res->{msg}  = "COMPARE FAIL :\nstdout: $run_res->{stdout}";
    }
    elsif ( !&CheckByType( $r_opts->{stderr}{type}, $run_res->{stderr}, $r_opts->{stderr}{must}))
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
