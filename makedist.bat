nmake
call pod2text <GuiTest.pm >README
tar cvf Win32-GuiTest.tar blib
gzip --best Win32-GuiTest.tar
nmake ppd
perl -npi.bak -e "s|<CODEBASE HREF=\"\" />|<CODEBASE HREF=\"Win32-GuiTest.tar.gz\" />|;" Win32-GuiTest.ppd
nmake zipdist

