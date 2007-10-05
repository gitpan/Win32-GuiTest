#!/usr/bin/perl
# $Id: which.pl,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $
# Similar to UNIX which command.
#
# On my NT box:
# 
#  D:\src\perl\win32-guitest>eg\which.pl perl
#  D:\perl\bin\perl.EXE
#  D:\src\perl\win32-guitest>eg\which.pl regedit
#  C:\WINNT\regedit.EXE
#  D:\src\perl\win32-guitest>eg\which.pl notepad
#  C:\WINNT\system32\notepad.EXE
#  D:\src\perl\win32-guitest>
#

use strict;
use Win32::GuiTest::Cmd qw(WhichExe);
print WhichExe(shift);
