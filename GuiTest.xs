/* 
 *	GuiTest.xs
 *
 *  The SendKeys function is based on the Delphi sourcecode
 *	published by Al Williams <http://www.al-williams.com/awc/> 
 *	in Dr.Dobbs <http://www.ddj.com/ddj/1997/careers1/wil2.htm>
 *	
 *	Copyright (c) 1998-2000 by Ernesto Guisado <erngui@acm.org>
 *
 *  You may distribute under the terms of either the GNU General Public
 *  License or the Artistic License.
 *
 */

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif


#define WIN32_LEAN_AND_MEAN
#include <windows.h>

int cvtkey(
	const char* s,
	int i, 
	int *key,
    int *count, 
	int* len,
    int* letshift,
    int* shift, 
	int* letctrl,
    int* ctrl, 
	int* letalt,
    int* alt, 
	int* shiftlock
	);


#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif


/*  Find the virtual keycode (Windows VK_* constants) given a 
 *  symbolic name.
 *  Returns 0 if not found.
 */
int findvkey(const char* name, int* key) 
{
    /* symbol table record */
    typedef struct tokentable {
        char *token;
        int vkey;
    } tokentable;

    /* global symbol table */
    static tokentable tbl[]  = {
        "BAC", VK_BACK,
        "BS" , VK_BACK,
        "BKS", VK_BACK,
        "BRE", VK_CANCEL,
        "CAP", VK_CAPITAL,
        "DEL", VK_DELETE,
        "DOW", VK_DOWN,
        "END", VK_END,
        "ENT", VK_RETURN,
        "ESC", VK_ESCAPE,
        "HEL", VK_HELP,
        "HOM", VK_HOME,
        "INS", VK_INSERT,
        "LEF", VK_LEFT,
        "NUM", VK_NUMLOCK,
        "PGD", VK_NEXT,
        "PGU", VK_PRIOR,
        "PRT", VK_SNAPSHOT,
        "RIG", VK_RIGHT,
        "SCR", VK_SCROLL,
        "TAB", VK_TAB,
        "UP",  VK_UP,
        "F1",  VK_F1,
        "F2",  VK_F2,
        "F3",  VK_F3,
        "F4",  VK_F4,
        "F5",  VK_F5,
        "F6",  VK_F6,
        "F7",  VK_F7,
        "F8",  VK_F8,
        "F9",  VK_F9,
        "F10",  VK_F10,
        "F11",  VK_F11,
        "F12",  VK_F12,
        "F13",  VK_F13,
        "F14",  VK_F14,
        "F15",  VK_F15,
        "F16",  VK_F16,
        "F17",  VK_F17,
        "F18",  VK_F18,
        "F19",  VK_F19,
        "F20",  VK_F20,
        "F21",  VK_F21,
        "F22",  VK_F22,
        "F23",  VK_F23,
        "F24",  VK_F24,
    };
    int i;
    for (i=0;i<sizeof(tbl)/sizeof(tokentable);i++) {
	    if (strcmp(tbl[i].token, name)==0) {
				*key=tbl[i].vkey;
                return 1;
		}
    }
    return 0;
}

/* Get a number from the input string */
int GetNum(
	const char*s ,
	int i,
	int* len
	)
{
	int res;
	int pos = 0;  
    char* tmp = (char*)safemalloc(strlen(s)+1);
    strcpy(tmp, s);
    OutputDebugString(tmp);
    OutputDebugString("GetNum2\n");
	while (s[i]>='0' && s[i]<='9') {
		tmp[pos++] = s[i++];
		(*len)++;
	}
    OutputDebugString("GetNum3\n");
	tmp[pos] = '\0';
	res = atoi(tmp);
    OutputDebugString("GetNum4\n");
	free(tmp);
    OutputDebugString("GetNum5\n");
	return res;
}



/* Process braced characters */
void procbrace(
	const char* s, 
	int i,
    int *key, 
	int *len,
    int *count, 
	int *letshift,
    int *letctrl,
	int *letalt,
    int *shift,
	int *ctrl,
    int *alt,
	int *shiftlock)
{
    int j,k,m;
	char* tmp = (char*)safemalloc(strlen(s)+1);
    strcpy(tmp, s);

    *count=1;
	/* 3 cases: x, xxx, xxx ## */
	/* if single character case */
	if (s[i+2]=='}' || s[i+2]==' ') {
		if (s[i+2]==' ') {      /* read count if present */
			*count=GetNum(s,i+3,len);
			(*len)++;
		}
		(*len)+=2;
		/* convert quoted key */
		*key= s[i+1];
		/* convert key -- pass -1 to prevent special interp. */
		cvtkey(s,-1,key,count,len,letshift,shift,
			letctrl,ctrl,letalt,alt,shiftlock);
    }
    else {  /* multicharacter sequence */
	
		*letshift=FALSE;
		*letctrl =FALSE;
		*letalt  =FALSE;
		
		/* find next brace or space */
		j=1;
		m = 0;
		while (s[i+j]!=' ' && s[i+j]!='}') {
		  tmp[m++]= s[i+j];
		  j++;
		  (*len)++;
		}
		tmp[m]='\0';
		
		if (s[i+j]==' ') {  /* read count */
		  *count=GetNum(s,i+j+1,len);
		  (*len)++;
		}
		(*len)++;
		
		/*check for special tokens*/
		for (k=0;k<(int)strlen(tmp); k++)
			tmp[k]=toupper(tmp[k]);
		
		/* chop token to 3 characters or less */
		if (strlen(tmp)>3) 
			tmp[3]='\0';

		/* handle pause specially */
		if (strcmp(tmp,"PAU")==0) {
            OutputDebugString("Found PAUSE\n");
			Sleep(*count);
			*key=0;
			free(tmp);
			return;
		}
		
		/* find entry in table */
		*key=0;
        findvkey(tmp, key);
		/* if key=0 here then something is bad */
	} /* end of token processing */

	free(tmp);
}

/* Wrapper around kebyd_event */
void keybd(int vk, int down)
{
	int scan;
	int flg;

	scan=MapVirtualKey(vk,0);  /* find VK */
	if (down)
		flg=0;
	else
		flg=KEYEVENTF_KEYUP;
	keybd_event(vk,scan,flg,0);
}

int cvtkey(
	const char* s,
	int i, 
	int *key,
    int *count, 
	int* len,
    int* letshift,
    int* shift, 
	int* letctrl,
    int* ctrl, 
	int* letalt,
    int* alt, 
	int* shiftlock
	)
{
	int rv;
	char c;
	int Result=FALSE;
	
	/* if i==-1 then supress special processing */
	if (i!=-1) { 
	  *len=1;
	  *count=1;
	}
	if (i!=-1)
		c=s[i];
	else 
		c=0;

	/* scan for special character */
    switch (c) {
    case '{': 
		procbrace(s,i,key,len,count,letshift,
			letctrl,letalt,shift,ctrl,alt,shiftlock);
        if (*key==0)
			return TRUE;
		break;
	case '~': *key=VK_RETURN; break;
    case '+': *shift=TRUE; Result=TRUE; break;
    case '^': *ctrl=TRUE; Result=TRUE; break;
    case '%': *alt=TRUE; Result=TRUE; break;
    case '(': *shiftlock=TRUE; Result=TRUE; break;
    case ')': *shiftlock=FALSE; Result=TRUE; break;
	default:
       if (c==0)
		   c=(char)*key;
       rv=VkKeyScan(c);  /* normal character */
       *key=rv & 0xFF;
       *letshift=((rv & 0x100)==0x100);
       *letctrl =((rv & 0x200)==0x200);
       *letalt  =((rv & 0x400)==0x400);
	};

	return Result;
}


typedef struct windowtable {
  int size;
  HWND* windows/*[1024]*/;
} windowtable; 


BOOL CALLBACK AddWindowChild(
  HWND hwnd,    // handle to child window
  LPARAM lParam // application-defined value
)
{
  HWND* grow;
  windowtable* children = (windowtable*)lParam;
  /* Need to grow the table to make space for the next entry */
  if (children->windows)
      grow = (HWND*)saferealloc(children->windows, (children->size+1)*sizeof(HWND));
  else
      grow = (HWND*)safemalloc((children->size+1)*sizeof(HWND));
  if (grow == 0)
    return FALSE;
  children->windows = grow;
  children->size++;
  children->windows[children->size-1] = hwnd;
  return TRUE;
}

/* 

Phill Wolf <pbwolf@bellatlantic.net> 
 
Although mouse_event is documented to take a unit of "pixels" when moving 
to an absolute location, and "mickeys" when moving relatively, on my 
system I can see that it takes "mickeys" in both cases.  Giving 
mouse_event an absolute (x,y) position in pixels results in the cursor 
going much closer to the top-left of the screen than is intended.
 
Here is the function I have used in my own Perl modules to convert from screen coordinates to mickeys.

*/

void ScreenToMouseplane(POINT *p)
{
    p->x = MulDiv(p->x, 0x10000, GetSystemMetrics(SM_CXSCREEN));
    p->y = MulDiv(p->y, 0x10000, GetSystemMetrics(SM_CYSCREEN));
}
 

/*  Same as mouse_event but without wheel and with time-out.
 */
VOID simple_mouse(
  DWORD dwFlags, // flags specifying various motion/click variants
  DWORD dx,      // horizontal mouse position or position change
  DWORD dy      // vertical mouse position or position change
 )
{
    char dstr[256];
    sprintf(dstr, "simple_mouse(%d, %d, %d)\n", dwFlags, dx, dy);
    OutputDebugString(dstr);
    mouse_event(dwFlags, dx, dy, 0, 0);
    Sleep (10);
}

MODULE = Win32::GuiTest		PACKAGE = Win32::GuiTest		

PROTOTYPES: DISABLE

void
SendLButtonUp()
	CODE:
        simple_mouse(MOUSEEVENTF_LEFTUP, 0, 0);

void
SendLButtonDown()
	CODE:
        simple_mouse(MOUSEEVENTF_LEFTDOWN, 0, 0);

void
SendMButtonUp()
	CODE:
        simple_mouse(MOUSEEVENTF_MIDDLEUP, 0, 0);

void
SendMButtonDown()
	CODE:
        simple_mouse(MOUSEEVENTF_MIDDLEDOWN, 0, 0);

void
SendRButtonUp()
	CODE:
        simple_mouse(MOUSEEVENTF_RIGHTUP, 0, 0);

void
SendRButtonDown()
	CODE:
        simple_mouse(MOUSEEVENTF_RIGHTDOWN, 0, 0);

void
SendMouseMoveRel(x,y)
    int x;
    int y;
	CODE:
        simple_mouse(MOUSEEVENTF_MOVE, x, y);

void
SendMouseMoveAbs(x,y)
	int x;
    int y;
	CODE:
        simple_mouse(MOUSEEVENTF_MOVE|MOUSEEVENTF_ABSOLUTE, x, y);

void
MouseMoveAbsPix(x,y)
	int x;
    int y;
    PREINIT:
        int mickey_x = MulDiv(x, 0x10000, GetSystemMetrics(SM_CXSCREEN));
        int mickey_y = MulDiv(y, 0x10000, GetSystemMetrics(SM_CYSCREEN));
	CODE:
        simple_mouse(MOUSEEVENTF_MOVE|MOUSEEVENTF_ABSOLUTE, mickey_x, mickey_y);


void
SendKeys(s)
     char* s
     PREINIT:
	int i,j;
	char c;
	int key;
	int count;

	/* init */
	int len=1;
	int shiftlock=FALSE;
	int letalt=FALSE;
	int alt=FALSE;
	int letctrl=FALSE;
	int ctrl=FALSE;
	int letshift=FALSE;
	int shift=FALSE;
	
	CODE:
     	
	/* for each character in string */
	for (i = 0; i < (int)strlen(s); i++) {
		
		if (len!=1) {  /* skip characters on request */
			len--;
			continue;
		}
		c=s[i];
		
		/* convert key */
		if (cvtkey(s,i,&key,&count,&len,&letshift,&shift,
			  &letctrl,&ctrl,&letalt,&alt,&shiftlock))
		  continue;
		
		/* fake modifier keys */
		if (shift || letshift) 
			keybd(VK_SHIFT,TRUE);
		if (ctrl || letctrl)
			keybd(VK_CONTROL,TRUE);
		if (alt || letalt)
			keybd(VK_MENU,TRUE);
		
		/* do requested number of keystrokes */
		for (j=0; j<count; j++) {
		  keybd(key,TRUE);
		  keybd(key,FALSE);
		  Sleep(50); /* wait 50ms*/
		}

		/* clear modifiers unless locked */
		if (alt || letalt && !shiftlock)
		   keybd(VK_MENU,FALSE);
		if (ctrl || letctrl && !shiftlock)
		   keybd(VK_CONTROL,FALSE);
		if (shift || letshift && !shiftlock)
		   keybd(VK_SHIFT,FALSE);
		if (!shiftlock) {
		  alt=FALSE;
		  ctrl=FALSE;
		  shift=FALSE;
		}
	}



HWND
GetDesktopWindow()
    CODE:
        RETVAL = GetDesktopWindow();
    OUTPUT:
	    RETVAL


HWND
GetWindow(hwnd, uCmd)
    HWND hwnd
    UINT uCmd
    CODE:
        RETVAL = GetWindow(hwnd, uCmd);
    OUTPUT:
	    RETVAL


SV*
GetWindowText(hwnd)
    HWND hwnd
    CODE:
        SV* sv;
        char text[255];
        int r;
        r = GetWindowText(hwnd, text, 255);
        RETVAL = newSVpv(text, r);
    OUTPUT:
        RETVAL

SV*
GetClassName(hwnd)
    HWND hwnd
    CODE:
        SV* sv;
        char text[255];
        int r;
        r = GetClassName(hwnd, text, 255);
        RETVAL = newSVpv(text, r);
    OUTPUT:
        RETVAL

HWND
GetParent(hwnd)
    HWND hwnd
    CODE:
        RETVAL = GetParent(hwnd);
    OUTPUT:
        RETVAL

long
GetWindowLong(hwnd, index)
    HWND hwnd
    int index
    CODE:
        RETVAL = GetWindowLong(hwnd, index);
    OUTPUT:
        RETVAL
        
    
BOOL 
SetForegroundWindow(hWnd)
    HWND hWnd
    CODE:
        RETVAL = SetForegroundWindow(hWnd);
    OUTPUT:
        RETVAL

HWND 
SetFocus(hWnd)
    HWND hWnd
    CODE:
        RETVAL = SetFocus(hWnd);
    OUTPUT:
        RETVAL

void
GetChildWindows(hWnd)
    HWND hWnd;
    PREINIT:
	    BOOL enum_ok;          
        windowtable children;
        int i;
        char buf[512];
    PPCODE:
	    children.size    = 0;
        children.windows = 0;
        EnumChildWindows(hWnd, (WNDENUMPROC)AddWindowChild, (LPARAM)&children);
        for (i = 0; i < children.size; i++) {
	        XPUSHs(sv_2mortal(newSViv((IV)children.windows[i])));
        }
		safefree(children.windows);
        

SV*
WMGetText(hwnd)
    HWND hwnd
    CODE:
        SV* sv;
        char* text;
        int len = SendMessage(hwnd, WM_GETTEXTLENGTH, 0, 0L); 
        text = (char*)safemalloc(len+1);
        if (text != 0) {
            SendMessage(hwnd, WM_GETTEXT, (WPARAM)len + 1, (LPARAM)text); 
            RETVAL = newSVpv(text, len);
            safefree(text);
        } else {
            RETVAL = 0;
        }
    OUTPUT:
        RETVAL
