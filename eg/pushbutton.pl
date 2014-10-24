#!/usr/bin/perl
# $Id: pushbutton.pl,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $
#

use strict;
use Win32::GuiTest qw(PushButton FindWindowLike SetForegroundWindow
    SendKeys WaitWindow IsWindow);

				  
# Test PushButton()

# Remove old saved document
unlink("C:\\temp\\PushButton.txt");

system("start notepad.exe");
my @windows = WaitWindow("Untitled - Notepad");
#my @windows = WaitWindow(" - Bloc de notas");
die unless scalar @windows == 1 && IsWindow($windows[0]);
SetForegroundWindow($windows[0]);
SendKeys("Sample Text\n");
SendKeys("%{F4}");
# Push Yes button to save document
PushButton("Yes");
#PushButton("S�");
# Type Filename
SendKeys("C:\\temp\\PushButton.txt");
# Push &Save to save and exit
PushButton("&Save");
#PushButton("&Guardar");
