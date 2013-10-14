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

    my $user = &GetUser( );

    my $r_mkws = &Execute( "mkdir -p \"$r_conf->{global_ws}\" && mktemp -d $r_conf->{global_ws}/$user.XXXX");
    return $FAIL if ( $r_mkws->{code});
    chomp $r_mkws->{stdout};
    my $ws = $r_mkws->{stdout};
    &SetWs    ( $ws);

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

    if ( $r_opts->{cfg_to_cp})
    {
        my @items = map{ $_ = &State::GetCfg( ) . "/$_" ; } split( ",",  $r_opts->{cfg_to_cp});

        foreach my $item ( @items)
        {
            my $res = &Execute( "cp -rf \"$item\" \"$ws\"");
            return $FAIL if ( $res->{code});
        }
    }
    return $PASS;
}


1;
