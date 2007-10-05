#!/usr/bin/perl
# $Id: rawkey.pl,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $
#

use Win32::GuiTest qw(:FUNC :VK);

while (1) {
    SendRawKey(VK_DOWN, KEYEVENTF_EXTENDEDKEY); 
    SendKeys "{PAUSE 200}";
}
