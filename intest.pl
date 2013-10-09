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
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use Getopt::Long qw ( GetOptions);

use Errors;
use Utils;
use Framework qw( GetVersion InitConf);
use Conf;

sub main
{
    my $test;
    my $test_opts = '';

    &GetOptions(
            "test|t=s"          => \$test,
            "test_options|opts|o=s"  => \$test_opts,
            "debug|d"           => \$Conf{debug},
            "verbose|v"         => \$Conf{verbose},
            "color"             => \$Conf{color},
            "html_log"          => \$Conf{html_log},
            "deep_log"          => \$Conf{deep_log},
    ) || die ( "Invalid options!!!");

    my $ver = &GetVersion;
    &Print( "=" x 80);
    &Print( "Start intest.");
    &Print( "  version:");
    &Print( $ver);
    &Print( "=" x 80);
    &InitConf( );
    &Print( "=" x 80);
    #&Print( &DumpHash( \%Conf));

    my $Opts = &ParseOptsString( $test_opts);
    my $res = &Framework::RunTest( $test, $Opts);

    &Print( "Result:");
    if ( $res->{code} == $PASS)
    {
        &Print( "PASSED");
    }
    else
    {
        &Print( "Failed");
    }
    &Print( &Utils::GetShortReport( $res));
    &Print( &DumpHash( $res), 0);
}








&main( );
