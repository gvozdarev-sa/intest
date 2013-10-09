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

    my $r_all_users = &LoadJSON( $r_opts->{users_file});

    my @users_for_testing;
    my %users_for_testing;
    if ( $r_opts->{users})
    {
        @users_for_testing = split( ",", $r_opts->{users});
    }
    else
    {
        @users_for_testing = keys %{ $r_all_users};
    }

    map { &PrintWarn( $_); $users_for_testing{ $_} = 1; } @users_for_testing;

    my $failed = 0;
    my $passed = 0;
    if ( $r_opts->{only_for_mentors})
    {
        my @mentors_filter = split( ",", $r_opts->{only_for_mentors});

        my $PASS_FILTER = 1;
        foreach my $user ( @users_for_testing)
        {
            my %mentors_from_user;
            map { $mentors_from_user{ $_} = 1; } @{ $r_all_users->{ $user}{mentors}};
            foreach my $mentor ( @mentors_filter)
            {
                if ( $mentors_from_user{ $mentor})
                {
                    $PASS_FILTER = 0;
                }
            }
            delete $users_for_testing{ $user};
        }
    }


    foreach my $user ( keys %users_for_testing)
    {
        &PrintWarn( "Run test for user : $user");

        my $r_mkws = &Execute( "mkdir -p \"$r_conf->{global_ws}\" && mktemp -d $r_conf->{global_ws}/$user.$r_opts->{test}.XXXX");
        #TODO check code
        chomp $r_mkws->{stdout};
        &SetWs    ( $r_mkws->{stdout});

        #TODO &SetTestLog( "&GetWs( )/log");

        &SetSrc   ( "$r_conf->{global_src}/$r_all_users->{ $user}{path}/$r_opts->{test}");
        &SetUser  ( $user);
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
    $r_res->{percentage}    = 100 * $passed / ( $passed + $failed) if ( $passed + $failed);
    return $r_res;
}


1;
