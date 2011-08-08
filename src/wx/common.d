/// Common structs that do not belong to any particular class
module wx.common;

/*! \mainpage
 *  <p><a href="http://wxd.sourceforge.net/"><b>wxD</b></a> is
 *  <a href="http://www.wxwidgets.org/">wxWidgets</a> bindings for the
 *  <a href="http://www.d-programming-language.org/">D programming language</a>.</p>
 */

/*! \namespace wx::libs
 *  \brief This module gets set to a pragma(link) for version(build).
 *
 *  It also does a pragma(export_version), for platform and encoding.
 */

//! \cond STD
version (Tango)
{
public import tango.stdc.stddef;
alias char[] string;
}
else // Phobos
{
public import std.c.stddef; // wchar_t
}
//! \endcond

interface IDisposable
{
	void Dispose();
}

interface ICloneable
{
	Object Clone();
}


	/// An implementation-specific type that is used to represent a pointer or a handle.
	typedef void* IntPtr;

version(UNICODE)
	alias wchar_t wxChar;
else //version(ANSI)
	alias ubyte wxChar;

//! \cond D1
static if (__VERSION__ < 1016)
//! \endcond
	static if (is(object.string)) { /*already added*/ } else
	alias char[] string; // added in DMD 1.016 and DMD 2.000


class NullPointerException : Exception
{
	this(string msg) { super(msg); }
}

class NullReferenceException : Exception
{
	this(string msg) { super(msg); }
}

class ArgumentException : Exception
{
	this(string msg) { super(msg); }
}

class InvalidOperationException : Exception
{
	this(string msg) { super(msg); }
}

class ArgumentNullException : Exception
{
	this(string msg) { super(msg); }
}


//public import wx.Defs;
public import wx.wxObject;
public import wx.wxString;
//public import wx.Log;
//public import wx.Event;
//public import wx.EvtHandler;
//public import wx.App;
//public import wx.Utils;

alias Point wxPoint;
struct Point
{
	int X,Y;

	/** struct constructor */
	static Point opCall(int x,int y)
	{
	    Point pt;
	    pt.X = x;
	    pt.Y = y;
	    return pt;
	}
}

alias Size wxSize;
struct Size
{
	int Width,Height;

	/** struct constructor */
	static Size opCall(int w,int h) {
	    Size sz;
	    sz.Width = w;
	    sz.Height = h;
	    return sz;
	}
}

alias Rectangle wxRectangle;
struct Rectangle
{
	int X,Y,Width,Height;
	int  Left() { return X; }
	void Left(int value) { X = value; }
	int  Top() { return Y; }
	void Top(int value) { Y = value; }

	int  Right() { return X + Width - 1; }
	void Right(int value) { Width = value - X + 1; }
	int  Bottom() { return Y + Height - 1; }
	void Bottom(int value) { Height = value - Y + 1; }

	/** struct constructor */
	static Rectangle opCall(int x,int y,int w,int h)
	{
	    Rectangle rect;
	    rect.X = x;
	    rect.Y = y;
	    rect.Width = w;
	    rect.Height = h;
	    return rect;
	}
}

alias Rect wxRect;
alias Rectangle Rect;

alias new_Rectangle new_Rect;


deprecated Point new_Point(int x,int y)
{
	return Point(x,y);
}

deprecated Size new_Size(int w,int h)
{
	return Size(w,h);
}

deprecated Rectangle new_Rectangle(int x,int y,int w,int h)
{
	return Rectangle(x,y,w,h);
}


