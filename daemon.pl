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
use lib "$FindBin::Bin/config/subtests/drivers";

use CGI qw/ :standard /;
use Data::Dumper;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use POSIX qw/ WNOHANG /;
use Getopt::Long qw ( GetOptions);

use Utils;
use Conf;

use constant HOSTNAME => qx{hostname};

my $d = HTTP::Daemon->new(
    LocalAddr => $Conf{daemon_host},
    LocalPort => $Conf{daemon_port},
    Reuse => 1,
) or die "Can't start http listener at $Conf{daemon_host}:$Conf{daemon_port}";


my %chld;
sub main
{
    &GetOptions(
            "debug|d"           => \$Conf{debug},
            "verbose|v"         => \$Conf{verbose},
            "color"             => \$Conf{color},
            "html_log"          => \$Conf{html_log},
            "deep_log"          => \$Conf{deep_log},
    ) || die ( "Invalid options!!!");

    &PrintC( "Started HTTP listener at " . $d->url);

    if ( $Conf{daemon_forks})
    {
        $SIG{CHLD} = sub
        {
            # checkout finished children
            while ( ( my $kid = waitpid( -1, WNOHANG)) > 0)
            {
                delete $chld{$kid};
            }
        };

        while ( 1)
        {
            # prefork all at once
            for ( scalar( keys %chld) .. $Conf{daemon_forks} - 1)
            {
                my $pid = fork;
                if ( !defined $pid)
                {
                    # error
                    die "Can't fork for http child $_: $!";
                }
                if ( $pid)
                {
                    # parent
                    $chld{$pid} = 1;
                }
                else
                {
                    # child
                    $_ = 'DEFAULT' for @SIG{qw/ INT TERM CHLD /};
                    &http_child( $d);
                    exit;
                }
            }
            sleep( 1);
        }
    }
    else
    {
        &http_child($d);
    }

}
sub http_child
{
    my $d = shift;

    my $i;
    while ( ++$i < $Conf{daemon_req_per_fork})
    {
        my $c = $d->accept          or last;
        my $r = $c->get_request( 1) or last;
        $c->autoflush( 1);

        &PrintC( sprintf("[%s] %s %s\n", $c->peerhost, $r->method, $r->uri->as_string));

        my %FORM = $r->uri->query_form();


        #TODO css must be in separate file
        my $css = '';
        $css .= ".console {\n background: #122;\n font-family: monospace; white-space :  pre-wrap;\n border : 3px; border-radius : 15px;\n margin : 10px;\n padding : 10px;\n }";
        $css .= ".msg {\n float: left\n}";
        $css .= ".msg_line {\n display: inline-block;\n float : none;\n min-width : 100%;\n}";
        $css .= ".debug_msg {\n color: #9e9;}";
        $css .= ".log_msg {\n color: #eee;}";
        $css .= ".info_msg {\n color: #fff;}";
        $css .= ".warn_msg {\n color: #ff0;}";
        $css .= ".error_msg {\n color: #f00;}";
        $css .= ".passed_msg {\n color: #0e0;}";
        $css .= "body {\n background: #AAA}";

        if ( $r->uri->path eq '/')
        {
            my $log = "<div class=\"console\">\n";
            my $flags = '';

            foreach my $flag ( keys %FORM)
            {
                $flags .= "--$flag \"" . $FORM{ $flag} . "\" ";
            }

            &PrintC( $flags);
            $log .= `perl intest.pl --deep --html $flags` . "\n";
            $log .= "</div>\n";

            &_http_response( $c, { content_type => 'text/html' },
                &start_html(
                    -title => HOSTNAME,
                    -encoding => 'utf-8',
                    -style => 'style.css',
                ),
                $log,
                &end_html(),
            )
        }
        elsif ( $r->uri->path eq '/style.css')
        {
            _http_response( $c, { content_type => 'text/css' }, $css);
        }
        else
        {
            _http_error( $c, RC_NOT_FOUND);
        }

        $c->close();
        undef $c;
    }
}

sub _http_error
{
    my ( $c, $code, $msg) = @_;

    $c->send_error( $code, $msg);
}

sub _http_response
{
    my $c = shift;
    my $options = shift;

    $c->send_response(
        HTTP::Response->new(
            RC_OK,
            undef,
            [
                'Content-Type' => $options->{content_type},
                'Cache-Control' => 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
                'Pragma' => 'no-cache',
                'Expires' => 'Thu, 01 Dec 1994 16:00:00 GMT',
            ],
            join( "\n", @_),
        )
    );
}


&main( );
