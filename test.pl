# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $loaded;}
use Win32::GuiTest;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my @wins = Win32::GuiTest::FindWindowLike(0, "", "", 0, 1);
for (@wins) {
    print "> $_ Text:>", Win32::GuiTest::GetWindowText($_), " ID:>", Win32::GuiTest::GetWindowID($_), "\n";
}
print "not " unless scalar @wins;
print "ok 2\n";

Win32::GuiTest::SendKeys("{PAUSE 1000}");
print "ok 3\n"; 


my $info = Win32::GuiTest::GetDesktopWindow();

print "::" ,$info , "\n";
print "ok 4\n";

system("start notepad.exe guitest.pm");
sleep 1;
my @windows = Win32::GuiTest::FindWindowLike(0, "Gui[tT]est", "Notepad");
print "not " unless scalar @windows == 1;
print "ok 5\n";
$notepad = @windows[0];
my @edits = Win32::GuiTest::FindWindowLike($notepad, "", "Edit");
print "not " unless scalar @edits == 1;
print "ok 6\n";
$content = Win32::GuiTest::WMGetText($edits[0]);
Win32::GuiTest::SendKeys("%{F4}");
open(GUI_FILE, "<guitest.pm");
@lines = <GUI_FILE>;
close GUI_FILE;
$file_content = join('', @lines);
print "not " unless  $content =~ /Win32::GuiTest/;
print "ok 7\n";
print "not " unless  $file_content =~ /Win32::GuiTest/;
print "ok 8\n";
