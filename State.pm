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

package State;

require Exporter;
@ISA    = qw( Exporter );
@EXPORT = qw(
SetSrc      GetSrc
SetCfg      GetCfg
SetWs       GetWs
SetUser     GetUser
SetEmail    GetEmail

);

###################################
use strict;
use File::Basename;
use Conf;

our %State =
(
    deep => 0,
);
#####
sub SetSrc
{
    my $src = shift;
    ###
    $State{src} = $src;
}

sub GetSrc
{
    return $State{src};
}
####
sub SetCfg
{
    my $cfg = shift;
    ###
    $State{cfg} = $cfg;
}

sub GetCfg
{
    return $State{cfg};
}
####

sub SetWs
{
    my $src = shift;
    ###
    $State{ws} = $src;
}

sub GetWs
{
    return $State{ws};
}
#####
sub SetUser
{
    my $user = shift;
    ###
    $State{user} = $user;
}

sub GetUser
{
    return $State{user};
}
####
sub SetEmail
{
    my $email = shift;
    ###
    $State{email} = $email;
}

sub GetEmail
{
    return $State{email};
}
###
sub PushDeep
{
    $State{deep}++;
}

sub PopDeep
{
    $State{deep}--;
}

sub GetDeep
{
    return $State{deep};
}

1;
