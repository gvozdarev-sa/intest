package clean_ws;
use strict;

BEGIN
{
    use File::Basename;
    my $dir = dirname dirname dirname dirname $0;
    push @INC, $dir;
}

use Utils;
use Errors;
use State;

sub Run
{
    my $r_opts = shift;
    my $r_conf = shift;

    my $ws = &GetWs( );

    if ( $r_opts->{rm_dir})
    {
        my $res = &Execute( "rm -rf \"$ws\"");
        if ( $res->{code})
        {
            return $FAIL;
        }
        else
        {
            return $PASS;
        }
    }


    if ( $r_opts->{clean_all})
    {
        my $ws = &State::GetWs( );
        my $res = &Execute( "rm -rf \"$ws\"");
        if ( $res->{code})
        {
            return $FAIL;
        }
        return $PASS;
    }

    my $r_items_to_rm = $r_opts->{dirs_to_rm};

    if ( $r_items_to_rm)
    {
        my @dirs = map{ $_ = "$ws/$_" ; } split( ",", $r_items_to_rm);

        foreach my $dir ( @dirs)
        {
            my $res = &Execute( "rm -rf \"$dir\"");
            if ( $res->{code})
            {
                return $FAIL;
            }
        }
    }

    return $PASS;
}


1;
