#!/usr/bin/perl
# $Id: keypress.pl,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $
# This example shows an easy way to check for certain keystrokes.
# The IsKeyPressed function takes a string with the name of the key.
# This names are the same ones as for SendKeys. 

use Win32::GuiTest qw(SendKeys IsKeyPressed);

# Wait until user presses several specified keys
@keys = qw/ESC F5 F11 F12 A B 8 DOWN/;

for (@keys) {
  until (IsKeyPressed($_)) {
    print "Please press $_...\n";
    SendKeys "{PAUSE 200}";
  }
}


