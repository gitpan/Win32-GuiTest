use Win32::GuiTest;

# If you have a notepad window open this prints the contents.
my @windows = Win32::GuiTest::FindWindowLike(0, "", "Notepad");
die "More than one notepad open" 
    unless scalar @windows == 1;
$notepad = @windows[0];
my @edits = Win32::GuiTest::FindWindowLike($notepad, "", "Edit");
die "More than one edit inside notepad" .  (scalar @edits) 
    unless scalar @edits == 1;
print "----------------------------------------------------------\n";
print Win32::GuiTest::WMGetText($edits[0]);
print "----------------------------------------------------------\n";


