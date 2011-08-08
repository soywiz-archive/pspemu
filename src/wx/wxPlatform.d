//-----------------------------------------------------------------------------
// wxD - wxPlatform.d
// (C) 2006 afb <afb@users.sourceforge.net>
//
/// The wxPlatform constants
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: wxPlatform.d,v 1.8 2010/10/11 09:31:37 afb Exp $
//-----------------------------------------------------------------------------

module wx.wxPlatform;
public import wx.common;

//! \cond STD
version (Tango)
{
}
else // Phobos
{
private import std.string;
}
//! \endcond

		// ------------------------------------------------------
		//! \cond EXTERN
		static extern (C) bool wxPlatform_WXMSW();
		static extern (C) bool wxPlatform_WXGTK();
		static extern (C) bool wxPlatform_WXMAC();
		static extern (C) bool wxPlatform_WXX11();
		static extern (C) bool wxPlatform_WXUNIVERSAL();

		static extern (C) bool wxPlatform_WXDEBUG();
		static extern (C) bool wxPlatform_UNIX();
		static extern (C) bool wxPlatform_UNICODE();
		static extern (C) bool wxPlatform_DISPLAY();
		static extern (C) bool wxPlatform_POSTSCRIPT();
		static extern (C) bool wxPlatform_GLCANVAS();
		static extern (C) bool wxPlatform_SOUND();

		static extern (C) IntPtr wxPlatform_wxGetOsDescription();
		static extern (C) int wxPlatform_wxGetOsVersion(ref int major, ref int minor);

		static extern (C) int wxPlatform_OS_UNKNOWN();
		static extern (C) int wxPlatform_OS_WINDOWS();
		static extern (C) int wxPlatform_OS_WINDOWS_9X();
		static extern (C) int wxPlatform_OS_WINDOWS_NT();
		static extern (C) int wxPlatform_OS_MAC();
		static extern (C) int wxPlatform_OS_MAC_OS();
		static extern (C) int wxPlatform_OS_DARWIN();
		static extern (C) int wxPlatform_OS_UNIX();
		static extern (C) int wxPlatform_OS_LINUX();
		static extern (C) int wxPlatform_OS_FREEBSD();
		//! \endcond
		// ------------------------------------------------------

/// Win platform
public bool __WXMSW__;
/// GTK platform
public bool __WXGTK__;
/// Mac platform
public bool __WXMAC__;
/// X11 platform
public bool __WXX11__;

/// Universal widgets
public bool __WXUNIVERSAL__;

/// Get OS description as a user-readable string
public string wxGetOsDescription()
{
	return cast(string) new wxString(wxPlatform_wxGetOsDescription(), true);
}

public bool ANSI;
public bool UNICODE;

public bool DEBUG;
public bool UNIX;

/// wxUSE_DISPLAY
public bool DISPLAY;
/// wxUSE_POSTSCRIPT
public bool POSTSCRIPT;
/// wxUSE_GLCANVAS
public bool GLCANVAS;
/// wxUSE_SOUND
public bool SOUND;

// ------------------------------------------------------

/// Unknown Platform
public int OS_UNKNOWN;
deprecated alias OS_UNKNOWN wxUNKNOWN_PLATFORM;

/// Windows
public int OS_WINDOWS;
/// Windows 95/98/ME
public int OS_WINDOWS_9X;
deprecated alias OS_WINDOWS_9X wxWIN95;
/// Windows NT/2K/XP
public int OS_WINDOWS_NT;
deprecated alias OS_WINDOWS_NT wxWINDOWS_NT;

/// Apple Mac OS
public int OS_MAC;
/// Apple Mac OS 8/9/X with Mac paths
public int OS_MAC_OS;
deprecated alias OS_MAC_OS wxMAC;
/// Apple Mac OS X with Unix paths
public int OS_DARWIN;
deprecated alias OS_DARWIN wxMAC_DARWIN;

/// Unix
public int OS_UNIX;
deprecated public int wxUNIX;
/// Linux
public int OS_LINUX;
/// FreeBSD
public int OS_FREEBSD;

/// Get OS version
public int wxGetOsVersion(ref int major, ref int minor)
{
	return wxPlatform_wxGetOsVersion(major, minor);
}

// ------------------------------------------------------

static this()
{
	__WXMSW__ = wxPlatform_WXMSW();
	__WXGTK__ = wxPlatform_WXGTK();
	__WXMAC__ = wxPlatform_WXMAC();
	__WXX11__ = wxPlatform_WXX11();

	__WXUNIVERSAL__ = wxPlatform_WXUNIVERSAL();

	// check that wxc matches wxd:
version(__WXMSW__)
	assert(__WXMSW__);
version(__WXGTK__)
	assert(__WXGTK__);
version(__WXMAC__)
	assert(__WXMAC__);
version(__WXX11__)
	assert(__WXX11__);

	UNICODE = wxPlatform_UNICODE();
	ANSI = !UNICODE;

	DEBUG = wxPlatform_WXDEBUG();
	UNIX = wxPlatform_UNIX();

	// check that wxc matches wxd:
version(UNICODE)
	assert(UNICODE);
else //version(ANSI)
	assert(ANSI);

	DISPLAY = wxPlatform_DISPLAY();
	POSTSCRIPT = wxPlatform_POSTSCRIPT();
	GLCANVAS = wxPlatform_GLCANVAS();
	SOUND = wxPlatform_SOUND();

	// constants
	OS_UNKNOWN = wxPlatform_OS_UNKNOWN();
	OS_WINDOWS = wxPlatform_OS_WINDOWS();
	OS_WINDOWS_9X = wxPlatform_OS_WINDOWS_9X();
	OS_WINDOWS_NT = wxPlatform_OS_WINDOWS_NT();
	OS_MAC = wxPlatform_OS_MAC();
	OS_MAC_OS = wxPlatform_OS_MAC_OS();
	OS_DARWIN = wxPlatform_OS_DARWIN();
	OS_UNIX = wxPlatform_OS_UNIX();
	OS_LINUX = wxPlatform_OS_LINUX();
	OS_FREEBSD = wxPlatform_OS_FREEBSD();

}

