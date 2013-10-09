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

package compile;
use strict;

BEGIN
{
    use File::Basename;
    my $dir = dirname dirname dirname dirname $0;
    push @INC, $dir;
}

use Utils;
use Errors;
use Framework qw ( CdWs );

sub Run
{
    my $r_opts      = shift;
    my $r_conf      = shift;
    my $r_tests_res = shift;
    ###
    my $r_res = &BlankRes;
    ###
    &CdWs( );
    my $cmd = "$r_opts->{compiler} $r_opts->{FLAGS} '$r_opts->{src_file}' -o $r_opts->{bin} $r_opts->{libs}";

    my $comp_res = &Execute( $cmd);

    if ( $comp_res->{code} != $PASS)
    {
        $r_res->{code} = $COMPFAIL;
        $r_res->{done} = 1;
        $r_res->{msg}  = "COMPILATION ERROR :\nstdout $comp_res->{stdout}\nstderr $comp_res->{stderr}\n";
    }
    else
    {
        $r_res->{code} = $PASS;
        $r_res->{done} = 1;
        $r_res->{msg}  = ( chomp $comp_res->{stdout}) ? ( "COMPILATION PASSED WITH :\nstdout\n$comp_res->{stdout}\n") : ( '');
    }

    return $r_res;
}


1;
