#!/usr/bin/perl
# $Id: spy--.pl,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $
# MS has a very nice tool (Spy++).
# This is Spy--
#

use Win32::GuiTest qw(FindWindowLike GetWindowText GetClassName
    GetChildDepth GetDesktopWindow);

for (FindWindowLike()) {
    $s = sprintf("0x%08X", $_ );
    $s .= ", '" .  GetWindowText($_) . "', " . GetClassName($_);
    print "+" x GetChildDepth(GetDesktopWindow(), $_), $s, "\n";
}
