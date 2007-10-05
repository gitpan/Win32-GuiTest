#!perl -w

# $Id: ask.pl,v 1.1.1.1 2007/10/05 08:30:20 dk Exp $
#
# Just ask a number of questions on the command line using
# the functions provided by Win32::GuiTest::Cmd

use strict;
use Win32::GuiTest::Cmd ':ALL';

Pause("Press ENTER to start the setup...");

print "GO!\n" if YesOrNo("Setup networking component?");

my $address = AskForIt("What's your new ip address?", 
    "122.122.122.122");

my $dir = AskForDir("Where should I put the new files?", 
    "c:\\temp");

my $exe = AskForExe("Where is your net setup program?", 
    "/foo/bar.exe");

print "\nAddress '$address'\n";
print "Dir     '$dir'\n";
print "Exe     '$exe'\n";
