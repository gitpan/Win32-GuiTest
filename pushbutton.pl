#! perl -w
# vim: ts=4

use strict;
use Win32::GuiTest qw/
    PushButton
    FindWindowLike 
    SetForegroundWindow
    SendKeys
    /;

				  
# Test PushButton()

# Remove old saved document
unlink("C:\\PushButton.txt");

system("start notepad.exe");
sleep(3);
my @windows = FindWindowLike(0, "Untitled - Notepad", "");
SetForegroundWindow($windows[0]) if scalar @windows == 1;
SendKeys("Sample Text\n");
SendKeys("%{F4}");
# Push Yes button to save document
PushButton("Yes");
# Type Filename
SendKeys("C:\\PushButton.txt");
# Push &Save to save and exit
PushButton("&Save");

