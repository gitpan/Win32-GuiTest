=head1 NAME

Win32::GuiTest - Perl GUI Test Utilities

=head1 SYNOPSIS

  use Win32::GuiTest qw(FindWindowLike GetWindowText 
    SetForegroundWindow SendKeys);

  $Win32::GuiTest::debug = 0; # Set to "1" to enable verbose mode

  my @windows = FindWindowLike(0, "^Microsoft Excel", "^XLMAIN\$");
  for (@windows) {
      print "$_>\t'", GetWindowText($_), "'\n";
      SetForegroundWindow($_);
      SendKeys("%fn~a{TAB}b{TAB}{BS}{DOWN}");
  }

=head1 INSTALLATION

    perl makefile.pl
    nmake
    nmake test
    nmake install

=head1 DESCRIPTION

Most GUI test scripts I have seen/written for Win32 use some variant of Visual
Basic (e.g. MS-VB or MS-Visual Test). The main reason is the availability of
the SendKeys function.

A nice way to drive Win32 programs from a test script is to use OLE Automation
(ActiveX Scripting), but not all Win32 programs support this interface. That's
where SendKeys comes handy.

Some time ago Al Williams published a Delphi version in Dr. Dobb's
(http://www.ddj.com/ddj/1997/careers1/wil2.htm). I ported it to C and
packaged it using h2xs...

The tentative name for this module is Win32::GuiTest (mostly because I plan to
include more GUI testing functions).

=head1 VERSION

    0.04

=head1 CHANGES


0.01  Wed Aug 12 21:58:13 1998

    - original version; created by h2xs 1.18

0.02  Sun Oct 25 20:18:17 1998

    - Added several Win32 API functions (typemap courtesy 
      of Win32::APIRegistry):
	SetForegroundWindow
	GetDesktopWindow 
	GetWindow 
	GetWindowText 
	GetClassName 
	GetParent
	GetWindowLong
	SetFocus

    - Ported FindWindowLike (MS-KB, Article ID: Q147659) from VB to
      Perl. Instead of using "like", I used Perl regexps. Why
      didn't Jeffrey Friedl include VB in "Mastering Regular
      Expressions"? ;-). 
	
0.03  Sun Oct 31 18:31:52 1999

    - Perhaps first version released thru CPAN (user: erngui).

    - Changed name from Win32::Test to Win32::GuiTest

    - Fixed bug: using strdup resulted in using system malloc and 
      perl's free, resulting in a runtime error.  
      This way we always use perl's malloc. Got the idea from
      'ext\Dynaloader\dl_aix.xs:calloc'.

0.04  Fri Jan 7 17:44:00 2000

    - Fixed Compatibility with ActivePerl 522. Thanks to
      Johannes Maehner <johanm@camline.com> for the initial patch.
      There were two main issues: 
        /1/ ActivePerl (without CAPI=TRUE) compiles extensions in C++ mode 
            (some casts from void*, etc.. were needed).
        /2/ The old typemap + buffers.h I was using had been rendered
            incompatible by changes in ActivePerl. As the incompatible typemaps
            were redundant, I deleted them. 
      Now it works on ActivePerl (both using 'perl makefile.pl' 
      and 'perl makefile.pl CAPI=TRUE') and on CPAN perl 
      (http://www.perl.com/CPAN/src/stable.zip). 

    - As requests for changes keep comming in, I've decided to put it all
      under version control (cvs if you're curious about it).	

=cut

package Win32::GuiTest;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $debug);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);

@EXPORT_OK = qw(SendKeys FindWindowLike SetForegroundWindow
GetDesktopWindow GetWindow GetWindowText GetClassName GetParent
		GetWindowID GetWindowLong $debug);


$VERSION = '0.4';

$debug = 0;

bootstrap Win32::GuiTest $VERSION;

sub GWL_ID      { -12;  }
sub GW_HWNDNEXT { 2;    }
sub GW_CHILD    { 5;    }   

=head1 FUNCTIONS

=over 8


=item $debug

When set enables the verbose mode.


=item SendKeys KEYS 

Sends keystrokes to the active window as if typed at the keyboard. 
The keystrokes to send are specified in KEYS. There are several
characters that have special meaning. This allows sending control codes 
and modifiers:
 
	~ means ENTER
	+ means SHIFT 
	^ means CTRL 
	% means ALT

The parens allow character grouping. You may group several characters, so that a specific keyboard modifier applies to all of them.

E.g. SendKeys("ABC") <=> SendKeys("+(abc)")

The curly braces are used to quote special characters (SendKeys("{+}{{}") sends a '+' and a '{'). You can also use them to specify certain named actions:

	Name              Action

	{BACKSPACE}       Backspace
	{BS}              Backspace
	{BKSP}            Backspace
	{BREAK}           Break
	{CAPS}            Caps Lock
	{DELETE}          Delete
	{DOWN}            Down arrow
	{END}             End
	{ENTER}           Enter (same as ~)
	{ESCAPE}          Escape
	{HELP}            Help key
	{HOME}            Home
	{INSERT}          Insert
	{LEFT}            Left arrow
	{NUMLOCK}         Num lock
	{PGDN}            Page down
	{PGUP}            Page up
	{PRTSCR}          Print screen
	{RIGHT}           Right arrow
	{SCROLL}          Scroll lock
	{TAB}             Tab
	{UP}              Up arrow
	{PAUSE}           Pause

All these named actions take an optional integer argument, like in {RIGHT 5}. 
For all of them, except PAUSE, the argument means a repeat count. For PAUSE it means the number of milliseconds SendKeys should pause before proceding.

In this implementation, SendKeys always returns after sending the keystrokes. There is no way to tell if an application has processed those keys when the function returns. 


=item FindWindowLike WINDOW, TITLEPATTERN, CLASSPATTERN, CHILDID 

Finds the window handles of the windows matching the specified parameters and
returns them as a list. 

You may specify the handle of the window to search under. The routine 
searches through all of this windows children and their children recursively.
If 'undef' then the routine searches through all windows. There is also a 
regexp used to match against the text in the window caption and another regexp
used to match against the text in the window class. If you pass a child ID 
number, the functions will only match windows with this id. In each case 
undef matches everything.

=back 

=cut 

sub FindWindowLike {
    my $hWndStart  = shift || GetDesktopWindow(); # Where to start
    my $WindowText = shift; # Regexp
    my $Classname  = shift; # Regexp
    my $ID         = shift; # Op. ID
    my $maxlevel   = shift; 
    my $level      = shift || 0; 

    my @found;

    if ($maxlevel && $level >= $maxlevel) {
		warn "Level $maxlevel reached\n" if $debug;
		return @found;
    }
 
    my $hwnd;
    my @hwnds;
    my $r;
    
    my $sWindowText;   
    my $sClassname;
    my $sID;
	
    $level++;
    
    # Get first child window:
    #$hwnd = GetWindow($hWndStart, GW_CHILD);
    #while ($hwnd) {
    @hwnds = GetChildWindows($hWndStart);
	warn "Children < @hwnds >\n" if $debug;
    for $hwnd (@hwnds) {
        # Search children by recursion:
        my @children = FindWindowLike($hwnd, $WindowText, 
				      $Classname, $ID, $maxlevel, $level);
	    push(@found, @children);

        # Get the window text and class name:   */
        $sWindowText = GetWindowText($hwnd);
        $sClassname  = GetClassName($hwnd);

		warn "($hwnd, $sWindowText, $sClassname) has ". scalar @children . 
			" children < @children >\n"
			if $debug;

        # If window is a child get the ID:   */
        if (GetParent($hwnd) != 0) {
            $r = GetWindowLong($hwnd, GWL_ID);   
            $sID = $r;   
        }
        # Check that window matches the search parameters:*/
        my $patwnd   = "$WindowText";
		my $patclass = "$Classname";
	
		warn "Using pattern ($patwnd, $patclass)\n" if $debug;

		if ((!$patwnd   || $sWindowText =~ /$patwnd/) && 
			(!$patclass || $sClassname =~ /$patclass/)) {
			warn "Matched $1\n" if $debug;
			if (!$ID){   
                # If find a match add handle to array:   
                #warn "Trying to push null wnd 1\n" unless $hwnd;
				push @found, $hwnd;
            } elsif ($sID) {   
                if ($sID == $ID) {
                    # If find a match add handle to array:
					#warn "Trying to push null wnd 2\n" unless $hwnd;
                    push @found, $hwnd;
				}   
            }   
            warn "Window Found: \n" . 
		"  Window Text  : $sWindowText\n" .
		    "  Window Class : $sClassname\n" .
			"  Window Handle: $hwnd\n" if $debug;   
        }
        # Get next child window:   
        #$hwnd = GetWindow($hwnd, GW_HWNDNEXT);   
    }
    # Decrement recursion counter:   
    $level--;
    # Return the windows found: 
	warn "FindWin found < @found >\n" if $debug;  
    return @found;
}

sub GetWindowID {
	return GetWindowLong(shift, GWL_ID);
}


# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__


=head1 COPYRIGHT

The SendKeys function is based on the Delphi sourcecode
published by Al Williams (http://www.al-williams.com/awc/) 
in Dr.Dobbs (http://www.ddj.com/ddj/1997/careers1/wil2.htm).

Copyright (c) 1998-2000 Ernesto Guisado. All rights reserved. This program 
is free software; You may distribute it and/or modify it under the 
same terms as Perl itself.

=head1 AUTHOR

Ernesto Guisado E<lt>erngui@acm.orgE<gt>

=cut


