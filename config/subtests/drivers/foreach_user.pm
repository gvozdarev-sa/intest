package foreach_user;
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
use State;

sub Run
{
    my $r_opts      = shift;
    my $r_conf      = shift;
    my $r_tests_res = shift;
    ###
    my $r_res = &BlankRes;
    ###

    my $r_users = &LoadJSON( $r_opts->{users});

    my $failed = 0;
    my $passed = 0;
    foreach my $user ( keys %$r_users)
    {
        #&SetTestLog( );
        &SetSrc   ( "$r_conf->{root}/src/$r_users->{ $user}{branch}");
        &SetUser  ( "$r_opts->{name}");
        &SetEmail ( $user);

        my %Opts;
        $r_res->{items_res}{ $user} =  &Framework::RunTest( $r_opts->{test}, \%Opts);
        if ( $r_res->{items_res}{ $user}{code} == $PASS)
        {
            $passed ++;
        }
        else
        {
            $failed ++;
        }
    }
    $r_res->{code}          = $PASS;
    $r_res->{done}          = 1;
    $r_res->{msg}           = "\npassed: $passed\nfailed: $failed\ntotal: " . ( $passed + $failed);
    $r_res->{percentage}    = 100 * $passed / ( $passed + $failed);
    return $r_res;
}


1;
