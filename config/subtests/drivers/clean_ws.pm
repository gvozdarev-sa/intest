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

sub Run
{
    my $r_opts = shift;
    my $r_conf = shift;

    my $r_items_to_rm = ( $r_opts->{clean_all}) ? (  "*" ) : ( $r_opts->{dirs_to_rm});

    if ( $r_items_to_rm)
    {
        my @dirs = map{ $_ = "$r_conf->{ws}/$_" ; } split( ",", $r_items_to_rm);

        foreach my $dir ( @dirs)
        {
            my $res = &Execute( "rm -rf $dir");
            if ( $res->{code})
            {
                return $FAIL;
            }
        }
    }
    return $PASS;
}


1;
