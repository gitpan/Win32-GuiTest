# $Id: keypress.pl,v 1.2 2001/11/04 19:11:58 erngui Exp $
#
# This example shows an easy way to check for certain keystrokes.
# The IsKeyPressed function takes a string with the name of the key.
# This names are the same ones as for SendKeys. 
use Win32::GuiTest qw/SendKeys IsKeyPressed/;

# Wait until user presses several
# specified keys
@keys = qw/ESC F5 F11 F2/;

for (@keys) {
  until (IsKeyPressed($_)) {
    print "Please press $_...\n";
    SendKeys "{PAUSE 50}";
  }
}


