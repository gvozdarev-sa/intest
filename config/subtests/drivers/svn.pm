package svn;
use strict;

BEGIN
{
    use File::Basename;
    my $dir = dirname dirname dirname dirname $0;
    push @INC, $dir;
}

use Utils;
use Errors;
use Framework;

sub Run
{
    my $r_opts      = shift;
    my $r_conf      = shift;
    my $r_tests_res = shift;
    ###
    my $r_res = &BlankRes;
    ###


    $r_res->{code}          = $PASS;
    $r_res->{done}          = 1;
    $r_res->{msg}           = "blunk";
    return $r_res;
}


1;
