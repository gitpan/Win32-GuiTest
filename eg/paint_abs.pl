#!perl -w
# $Id: paint_abs.pl,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $
#
# Draw an X and a box around it
#
use strict;
use Win32::GuiTest qw(FindWindowLike SetForegroundWindow 
    SendMouse MouseMoveAbsPix SendLButtonDown SendLButtonUp);

system("start /max mspaint");
sleep 2;
my @windows = FindWindowLike(0, "Paint", "");
die "Could not find Paint\n" if not @windows;

SetForegroundWindow($windows[0]);
sleep 1;

#Using low level functions
MouseMoveAbsPix(100,100);
SendLButtonDown();
MouseMoveAbsPix(300,300);
SendLButtonUp();


sleep 1;

MouseMoveAbsPix(100,300);
SendLButtonDown();
MouseMoveAbsPix(300,100);
SendLButtonUp();

sleep 1;
    
MouseMoveAbsPix(100,100);
SendLButtonDown();
MouseMoveAbsPix(300,100);
MouseMoveAbsPix(300,300);
MouseMoveAbsPix(100,300);
MouseMoveAbsPix(100,100);
SendLButtonUp();

