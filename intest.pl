############################################################################################
# Copyright (C) 2013 Sergey Gvozdarev https://github.com/gvozdarev-sa/intest
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom
# the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
############################################################################################

use strict;

use FindBin;
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/config/subtests/drivers";

use Getopt::Long qw ( GetOptions);

use Errors;
use Utils qw( Print  Execute LoadJSON DumpHash);
use Framework qw( GetVersion InitConf);
use Conf;

sub main
{
    my $test;
    my $opts;
    my $debug;
    my $verbose;
    my $color;

    &GetOptions(
            "test|t=s"          => \$test,
            "options|opts|o=s"  => \$opts,
            "debug|d"           => \$debug,
            "verbose|v"         => \$verbose,
            "color"             => \$color,
    ) || die ( "Invalid options!!!");

    $Conf{debug}   = 1 if ( $debug);
    $Conf{verbose} = 1 if ( $verbose);
    $Conf{color}   = 1 if ( $color);

    my $ver = &GetVersion;
    &Print( "===============================");
    &Print( "Start intest.");
    &Print( "  version:");
    &Print( $ver);
    &Print( "===============================");
    &InitConf( );

    &Print( &DumpHash( \%Conf));

    my %Opts;
    my $res = &Framework::RunTest( $test, \%Opts);

    &Print( "Result:");
    if ( $res->{code} == $PASS)
    {
        &Print( "PASSED");
    }
    else
    {
        &Print( "Failed");
    }
    &Print( "  code       : " . $res->{code});
    &Print( "  percentage : " . $res->{percentage});
    &Print( "  msg        : " . $res->{msg});
    &Print( &DumpHash( $res), 0);

}








&main( );
