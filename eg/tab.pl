#!/usr/bin/perl
# $Id: tab.pl,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $
#

use Win32::GuiTest qw(:FUNC :VK);

SendRawKey(VK_MENU, 0);
SendKeys("{TAB}{PAU 1000}{TAB}{PAU 1000}{TAB}");
SendRawKey(VK_MENU, KEYEVENTF_KEYUP);

