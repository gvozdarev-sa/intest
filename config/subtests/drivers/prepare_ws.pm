package prepare_ws;
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

    if ( $r_opts->{clean_ws})
    {
        my $res;
        $res = &Execute( "rm -rf \"$ws\"");
        return $FAIL if ( $res->{code});

        $res = &Execute( "mkdir -p \"$ws\"");
        return $FAIL if ( $res->{code});
    }

    if ( $r_opts->{dirs_to_mk})
    {
        my @dirs = map{ $_ = "$ws/$_" ; } split( ",",  $r_opts->{dirs_to_mk});

        foreach my $dir ( @dirs)
        {
            my $res = &Execute( "mkdir -p \"$dir\"");
            return $FAIL if ( $res->{code});
        }
    }

    if ( $r_opts->{src_to_cp})
    {
        my @items = map{ $_ = &State::GetSrc( ) .  "/$_" ; } split( ",", $r_opts->{src_to_cp});

        foreach my $item ( @items)
        {
            my $res = &Execute( "cp -rf \"$item\" \"$ws\"");
            return $FAIL if ( $res->{code});
        }
    }

    if ( $r_opts->{conf_to_cp})
    {
        my @items = map{ $_ = "$r_conf->{conf}/$_" ; } split( ",",  $r_opts->{conf_to_cp});

        foreach my $item ( @items)
        {
            my $res = &Execute( "cp -rf \"$item\" \"$ws\"");
            return $FAIL if ( $res->{code});
        }
    }
    return $PASS;
}


1;
