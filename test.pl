# $Id: test.pl,v 1.6 2001/06/02 21:46:20 erngui Exp $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
BEGIN { $| = 1; print "1..15\n"; }
END {print "not ok 1\n" unless $loaded;}
use Win32::GuiTest qw/
    FindWindowLike
    GetChildDepth
    GetChildWindows
    GetClassName
    GetDesktopWindow
    GetWindowText
    SendKeys
    SetForegroundWindow
    WMGetText
    /;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# Check that there are no duplicate windows in the list
my @wins = FindWindowLike();
my %found;
my $dup;
for (@wins) {
    $dup = 1 if $found{$_};
    $found{$_} = 1;
}
print "not " unless scalar @wins && !$dup;
print "ok 2\n";

# Just use SenKeys as pause
SendKeys("{PAUSE 1000}");
print "ok 3\n"; 

# The desktop should never be on the window list
my $root = GetDesktopWindow();
my @desks = grep { $_ == $root } @wins;
print "not " if scalar @desks;
print "ok 4\n";

# Create a notepad window and check we can find it
system("start notepad.exe guitest.pm");
sleep 1;
my @windows = FindWindowLike(0, "Gui[tT]est", "Notepad");
print "not " unless scalar @windows == 1;
print "ok 5\n";

# Find the edit window inside notepad
$notepad = @windows[0];
my @edits = FindWindowLike($notepad, "", "Edit");
print "not " unless scalar @edits == 1;
print "ok 6\n";

# Get the contents (should be the GuiTest.pm file)
$content = WMGetText($edits[0]);
SendKeys("%{F4}");
open(GUI_FILE, "<guitest.pm");
@lines = <GUI_FILE>;
close GUI_FILE;
$file_content = join('', @lines);
print "not " unless  $content =~ /Win32::GuiTest/;
print "ok 7\n";
print "not " unless  $file_content =~ /Win32::GuiTest/;
print "ok 8\n";

# Open a notepad and type some text into it
system("start notepad.exe");
sleep 1;
@windows = FindWindowLike(0, "", "Notepad");
print "not " unless scalar @windows == 1;
print "ok 9\n";

SendKeys(<<EOM);
    This is a test message,
    but also a little demo for the
    SendKeys function.
    3, 2, 1, 0...
    Closing Notepad...{PAU 400}%{F4}{TAB}{ENTER}
EOM

# We closed it so there should be no notepad open
sleep 1;
@windows = FindWindowLike(0, "", "Notepad");
print "not " unless scalar @windows == 0;
print "ok 10\n";

# Since we are looking for child windows, all of them should have
# depth of 1 or more
my $desk = GetDesktopWindow();
my @childs =  GetChildWindows($desk);
my @badchilds = grep {  GetChildDepth($desk, $_) < 1  } @childs;
print "not " unless scalar @badchilds == 0;
print "ok 11\n";

# If you don't specify patterns, etc, FindWindowLike is equivalent to
# GetChildWindows (meaning all the windows)
my @all = GetChildWindows($desk);
my @some = FindWindowLike($desk);
print "not " unless @all == @some;
print "ok 12\n";

# Look for any MFC windows and do sanity check
my @mfc = FindWindowLike($desk, "", "^[Aa]fx");
print "not " unless (grep { GetClassName($_) =~ /^[aA]fx/  } @mfc) == @mfc;
print "ok 13\n";

# Look for any sys windows and do sanity check
my @sys = FindWindowLike($desk, "", "^Sys");
print "not " unless (grep { GetClassName($_) =~ /^Sys/  } @sys) == @sys;
print "ok 14\n";

# Loop increasing window search depth until increasing the depth returns
# no more windows
my $depth = 1;
@wins = FindWindowLike($desk, "", "", undef, $depth);
@next = FindWindowLike($desk, "", "", undef, $depth+1);
while (scalar(@next) > scalar(@wins)) {
    $depth++;
    @wins = @next;
    @next = FindWindowLike($desk, "", "", undef, $depth+1);
}

# The maximun reached depth should contain all the windows
print "not " unless FindWindowLike($desk, "", "", undef, $depth) == @all;
print "ok 15\n";



