package git;
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


    my $src_dir = $r_conf->{global_src};
    if ( $r_opts->{clone})
    {
        my $res;

        $res = &Execute( "rm -rf \"$src_dir\"&& mkdir -p \"$src_dir\" && git clone \"$r_opts->{repo}\"  \"$src_dir\"");
        return $FAIL if ( $res->{code});
    }

    if ( $r_opts->{pull})
    {
        my $res;
        $res = &Execute( "git pull \"$r_opts->{repo}\" \"$src_dir\"");
        return $FAIL if ( $res->{code});
    }

    return $PASS;
}


1;
