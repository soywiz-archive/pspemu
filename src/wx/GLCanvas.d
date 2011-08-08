//-----------------------------------------------------------------------------
// wxD - GLCanvas.d
// (C) 2006 afb <afb@users.sourceforge.net>
// 
/// The wxGLCanvas wrapper classes. (Optional, requires OpenGL)
//
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: GLCanvas.d,v 1.8 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.GLCanvas;
public import wx.common;
public import wx.Window;
public import wx.Palette;

	//---------------------------------------------------------------------------
	// Constants for attriblist
	//---------------------------------------------------------------------------
	
	// The generic GL implementation doesn't support most of these options,
	// such as stereo, auxiliary buffers, alpha channel, and accum buffer.
	// Other implementations may actually support them.
	
	enum
	{
		WX_GL_RGBA=1,          /* use true color palette */
		WX_GL_BUFFER_SIZE,     /* bits for buffer if not WX_GL_RGBA */
		WX_GL_LEVEL,           /* 0 for main buffer, >0 for overlay, <0 for underlay */
		WX_GL_DOUBLEBUFFER,    /* use doublebuffer */
		WX_GL_STEREO,          /* use stereoscopic display */
		WX_GL_AUX_BUFFERS,     /* number of auxiliary buffers */
		WX_GL_MIN_RED,         /* use red buffer with most bits (> MIN_RED bits) */
		WX_GL_MIN_GREEN,       /* use green buffer with most bits (> MIN_GREEN bits) */
		WX_GL_MIN_BLUE,        /* use blue buffer with most bits (> MIN_BLUE bits) */
		WX_GL_MIN_ALPHA,       /* use blue buffer with most bits (> MIN_ALPHA bits) */
		WX_GL_DEPTH_SIZE,      /* bits for Z-buffer (0,16,32) */
		WX_GL_STENCIL_SIZE,    /* bits for stencil buffer */
		WX_GL_MIN_ACCUM_RED,   /* use red accum buffer with most bits (> MIN_ACCUM_RED bits) */
		WX_GL_MIN_ACCUM_GREEN, /* use green buffer with most bits (> MIN_ACCUM_GREEN bits) */
		WX_GL_MIN_ACCUM_BLUE,  /* use blue buffer with most bits (> MIN_ACCUM_BLUE bits) */
		WX_GL_MIN_ACCUM_ALPHA  /* use blue buffer with most bits (> MIN_ACCUM_ALPHA bits) */
	}

	//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) void wxGLContext_SetCurrent(IntPtr self, IntPtr canvas);
		static extern (C) void wxGLContext_Update(IntPtr self);
		static extern (C) void wxGLContext_SetColour(IntPtr self, string colour);
		static extern (C) void wxGLContext_SwapBuffers(IntPtr self);
		static extern (C) IntPtr wxGLContext_GetWindow(IntPtr self);
		//! \endcond

		//-----------------------------------------------------------------------------

	alias GLContext wxGLContext;
	public class GLContext : wxObject
	{
		public this(IntPtr wxobj)
		{ 
			super(wxobj);
		}
		
		public void SetCurrent(GLCanvas canvas = null)
		{
			wxGLContext_SetCurrent(wxobj, wxObject.SafePtr(canvas));
		}

		public void Update()
		{
			wxGLContext_Update(wxobj);
		}
		
		public void SetColour(string colour)
		{
			wxGLContext_SetColour(wxobj, colour);
		}

		public void SwapBuffers()
		{
			wxGLContext_SwapBuffers(wxobj);
		}

		public Window window()
		{
			return new Window( wxGLContext_GetWindow(wxobj) );
		}
	}

		//-----------------------------------------------------------------------------

		//! \cond EXTERN
		static extern (C) IntPtr wxGLCanvas_ctor(IntPtr parent, int id, ref Point pos, ref Size size, uint style, string name, int* attribList, ref Palette palette);
		static extern (C) IntPtr wxGLCanvas_ctor2(IntPtr parent, IntPtr shared_, int id, ref Point pos, ref Size size, uint style, string name, int* attribList, ref Palette palette);
		static extern (C) IntPtr wxGLCanvas_ctor3(IntPtr parent, IntPtr shared_, int id, ref Point pos, ref Size size, uint style, string name, int* attribList, ref Palette palette);

		static extern (C) void wxGLCanvas_SetCurrent(IntPtr self);
		static extern (C) void wxGLCanvas_UpdateContext(IntPtr self);
		static extern (C) void wxGLCanvas_SetColour(IntPtr self, string colour);
		static extern (C) void wxGLCanvas_SwapBuffers(IntPtr self);
		static extern (C) IntPtr wxGLCanvas_GetContext(IntPtr self);
		//! \endcond
		
		//-----------------------------------------------------------------------------

	alias GLCanvas wxGLCanvas;
	public class GLCanvas : Window
	{
		public static Palette wxNullPalette = null;
		const string wxGLCanvasStr = "GLCanvas";

		public this(Window parent, int id, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=0, string name=wxGLCanvasStr,int* attribList=null, Palette palette=wxNullPalette)
			{ this(wxGLCanvas_ctor(wxObject.SafePtr(parent), id, pos, size, style, name, attribList, palette), true); }
		
		public this(Window parent, GLContext shared_, int id, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=0, string name=wxGLCanvasStr,int* attribList=null, Palette palette=wxNullPalette)
			{ this(wxGLCanvas_ctor2(wxObject.SafePtr(parent), wxObject.SafePtr(shared_), id, pos, size, style, name, attribList, palette), true); }
		
		public this(Window parent, GLCanvas shared_, int id, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=0, string name=wxGLCanvasStr,int* attribList=null, Palette palette=wxNullPalette)
			{ this(wxGLCanvas_ctor3(wxObject.SafePtr(parent), wxObject.SafePtr(shared_), id, pos, size, style, name, attribList, palette), true); }

		public this(Window parent, Point pos=wxDefaultPosition, Size size=wxDefaultSize, int style=0, string name=wxGLCanvasStr,int* attribList=null, Palette palette=wxNullPalette)
			{ this(parent, Window.UniqueID, pos, size, style, name, attribList, palette); }

		public this(IntPtr wxobj) 
		{
			super(wxobj);
		}
		
		private this(IntPtr wxobj, bool memOwn)
		{ 
			super(wxobj);
			this.memOwn = memOwn;
		}

		public void SetCurrent()
		{
			wxGLCanvas_SetCurrent(wxobj);
		}

		public void UpdateContext()
		{
			wxGLCanvas_UpdateContext(wxobj);
		}
		
		public void SetColour(string colour)
		{
			wxGLCanvas_SetColour(wxobj, colour);
		}

		public void SwapBuffers()
		{
			wxGLCanvas_SwapBuffers(wxobj);
		}

		public GLContext context()
		{
			IntPtr wxctx = wxGLCanvas_GetContext(wxobj);
			return wxctx ? new GLContext(wxctx) : null;
		}
		
	}
