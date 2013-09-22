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

sub Run
{
    my $r_opts = shift;
    my $r_conf = shift;


    if ( $r_opts->{clean_ws})
    {
        my $res;
        $res = &Execute( "rm -rf $r_conf->{ws}");
        return $FAIL if ( $res->{code});

        $res = &Execute( "mkdir -p $r_conf->{ws}");
        return $FAIL if ( $res->{code});
    }

    if ( $r_opts->{dirs_to_mk})
    {
        my @dirs = map{ $_ = "$r_conf->{ws}/$_" ; } split( ",",  $r_opts->{dirs_to_mk});

        foreach my $dir ( @dirs)
        {
            my $res = &Execute( "mkdir -p $dir");
            return $FAIL if ( $res->{code});
        }
    }

    if ( $r_opts->{src_to_cp})
    {
        my @items = map{ $_ = "$r_conf->{src}/$_" ; } split( ",", $r_opts->{src_to_cp});

        foreach my $item ( @items)
        {
            my $res = &Execute( "cp -rf $item $r_conf->{ws}");
            return $FAIL if ( $res->{code});
        }
    }

    if ( $r_opts->{conf_to_cp})
    {
        my @items = map{ $_ = "$r_conf->{conf}/$_" ; } split( ",",  $r_opts->{conf_to_cp});

        foreach my $item ( @items)
        {
            my $res = &Execute( "cp -rf $item $r_conf->{ws}");
            return $FAIL if ( $res->{code});
        }
    }
    return $PASS;
}


1;
