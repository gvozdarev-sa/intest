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

package Errors;

require Exporter;
@ISA    = qw( Exporter );
@EXPORT = qw(
$PASS

$BADTEST
$RUNFAIL
$DEPFAIL
$COMPFAIL
$CMPFAIL

$FAIL
);

###################################################
use strict;

our $PASS       = 0;
our $BADTEST    = 1;
our $RUNFAIL    = 2;
our $DEPFAIL    = 4;
our $COMPFAIL   = 8;
our $CMPFAIL    = 16;


our $FAIL       = 256;

our $str_errors =
{
    $PASS     => "PASS",
    $BADTEST  => "BADTEST",
    $RUNFAIL  => "RUNFAIL",
    $COMPFAIL => "COMPFAIL",
    $DEPFAIL  => "DEPFAIL",
    $CMPFAIL  => "CMPFAIL",
    $FAIL     => "FAIL",
};

1;
