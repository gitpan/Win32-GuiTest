#!/usr/bin/perl
# $Id: showmouse.pl,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $
# This script has been written by Jarek Jurasz jurasz@imb.uni-karlsruhe.de

use Win32::GuiTest qw(GetCursorPos);

while (1)
{
  ($x, $y) = GetCursorPos();
  print "\rx:$x  y:$y   ";
  sleep 1;
}

