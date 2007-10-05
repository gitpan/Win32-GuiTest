#!perl -w
BEGIN { $| = 1; }

# $Id: 04_std.t,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $

use strict;
use Test::More qw(no_plan);

use Win32::GuiTest qw/
    GetDesktopWindow
    IsWindow
    /;

# Standard Check
ok(IsWindow(GetDesktopWindow()));
