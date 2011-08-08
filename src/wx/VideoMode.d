//-----------------------------------------------------------------------------
// wxD - VidMode.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - VidMode.cs
//
/// The VideoMode class
//
// Michael S. Muegel mike _at_ muegel dot org
//
// Given this is such a simple structure I did a full port of it's C++ 
// counterpart instead of using a wrapper.
//
// Changes/Additions to C++ version:
//    + ToString() method for simple formatting of display properties
//    + Implemented IComparable to allow for simple sorting of modes
//    + Did not implement IsOK -- maybee I did not understand it but
//      it seems impossible to not be true.
//
// Note that == and the Matches method differ in how they work. == is
// true equality of all properties. Matches implements the wxWidgets
// concept of display equivalence.
//
// VideoMode is immutable: it can not be modified once created, either manually
// via it's constructor or more likely by calling a method in Display.
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// $Id: VideoMode.d,v 1.15 2009/04/28 11:11:50 afb Exp $
//-----------------------------------------------------------------------------

module wx.VideoMode;
public import wx.common;

//! \cond STD
version (Tango)
{
import tango.core.Version;
import tango.text.convert.Integer;
}
else // Phobos
{
private import std.string;
private import std.conv;
}
//! \endcond

//    [StructLayout(LayoutKind.Sequential)]

        deprecated public VideoMode new_VideoMode(int width, int height, int depth, int freq)
        {
            return VideoMode(width, height, depth, freq);
        }

    public struct VideoMode // : IComparable
    {
        /** struct constructor */
        public static VideoMode opCall(int width, int height, int depth, int freq)
        {
            VideoMode v;
            v.w = width;
            v.h = height;
            v.bpp = depth;
            v.refresh = freq;
            return v;
        }
/+
		public int opCmp(VideoMode other)
		{
		//	VideoMode other = cast(VideoMode) obj;
			if (other.w > w)
				return -1;
			else if (other.w < w)
				return 1;
			else if (other.h > h)
				return -1;
			else if (other.h < h)
				return 1;
			else if (other.bpp > bpp)
				return -1;
			else if (other.bpp < bpp)
				return 1;
			else if (other.refresh > refresh)
				return -1;
			else if (other.refresh < refresh)
				return 1;
			else
				return 0;
		}

        public override int opEquals(Object obj)
        {
            if (obj === null) return false;
            VideoMode other = cast(VideoMode) obj;
            return (w == other.w) && (h == other.h) && 
                (bpp == other.bpp) && (refresh == other.refresh);
        }

        public override uint toHash()
        {
            return w ^ h ^ bpp ^ refresh;
        }
+/
        // returns true if this mode matches the other one in the sense that all
        // non zero fields of the other mode have the same value in this one
        // (except for refresh which is allowed to have a greater value)
        public bool Matches(VideoMode other)
        {
            return (other.w == 0 || w == other.w) &&
                (other.h == 0 || h == other.h) &&
                (other.bpp == 0 || bpp == other.bpp) &&
                (other.refresh == 0 || refresh >= other.refresh);
        }

        // trivial accessors
        public int Width() { return w; }

        public int Height() { return h; }

        public int Depth() { return bpp; }

        // This is not defined in vidmode.h
        public int RefreshFrequency() { return refresh; }


        // returns true if the object has been initialized
        // not implemented -- seems impossible
        // bool IsOk() const { return w && h; }

	version (Tango)
	{
	  static if (Tango.Major == 0 && Tango.Minor < 994)
	  {
		public char[] toUtf8()
		{
			char[] s;
			s = tango.text.convert.Integer.toUtf8(w) ~ "x" ~ tango.text.convert.Integer.toUtf8(h);
			if ( bpp > 0 )
				s ~= ", " ~ tango.text.convert.Integer.toUtf8(bpp) ~ "bpp";
			if ( refresh > 0 )
				s ~= ", " ~ tango.text.convert.Integer.toUtf8(refresh) ~ "Hz";
			return s;
		}
	  }
	  else
	  {
		public string toString()
		{
			string s;
			s = tango.text.convert.Integer.toString(w) ~ "x" ~ tango.text.convert.Integer.toString(h);
			if ( bpp > 0 )
				s ~= ", " ~ tango.text.convert.Integer.toString(bpp) ~ "bpp";

			if ( refresh > 0 )
				s ~= ", " ~ tango.text.convert.Integer.toString(refresh) ~ "Hz";

			return s;
		}
	  }
	}
	else // Phobos
	{
		public string toString()
		{
			string s;
			version (D_Version2)
			{
			s = to!(string)(w) ~ "x" ~ to!(string)(h);
			if ( bpp > 0 )
				s ~= ", " ~ to!(string)(bpp) ~ "bpp";

			if ( refresh > 0 )
				s ~= ", " ~ to!(string)(refresh) ~ "Hz";
			}
			else
			{
			s = .toString(w) ~ "x" ~ .toString(h);
			if ( bpp > 0 )
				s ~= ", " ~ .toString(bpp) ~ "bpp";

			if ( refresh > 0 )
				s ~= ", " ~ .toString(refresh) ~ "Hz";
			}

			return s;
		}
	}

        // the screen size in pixels (e.g. 640*480), 0 means unspecified
        private int w, h;

        // bits per pixel (e.g. 32), 1 is monochrome and 0 means unspecified/known
        private int bpp;

        // refresh frequency in Hz, 0 means unspecified/unknown
        private int refresh;
    }
