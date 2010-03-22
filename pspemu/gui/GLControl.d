//============================================================================
// glcontrol.d - OpenGL Control
//
// Description: 
//   An OpenGL rendering widget for DFL (http://wiki.dprogramming.com/Dfl)
//
// Version: 0.21
// Contributors: Anders Bergh, Bill Baxter, Julian Smart
// Written in the D Programming Language (http://www.digitalmars.com/d)
//============================================================================

module pspemu.gui.GLControl;

public import pspemu.utils.OpenGL;

import dfl.all, dfl.internal.winapi;
import std.stdio;
import std.windows.syserror;

extern (Windows) {
	bool  SetPixelFormat(HDC, int, PIXELFORMATDESCRIPTOR*);
	bool  SwapBuffers(HDC);
	int   ChoosePixelFormat(HDC, PIXELFORMATDESCRIPTOR*);
}

class GLControl : Control {
    GLContext _context;
    protected HDC _hdc;
    
    this() {  }
    this(GLContext share_with) { _context = share_with;  }
	this(GLControl share_with) { _context = share_with._context; }

    override void onHandleCreated(EventArgs ea) {
        _hdc = cast(HANDLE) (cast(void*)GetDC(handle));
        setupPixelFormat();
		
        _context = new GLContext(this,_context);
        makeCurrent();
		glInit();

        initGL();

        onResize(EventArgs.empty);

        invalidate();
        
        super.onHandleCreated(ea);
    }
    
    override void onHandleDestroyed(EventArgs ea) {
        wglMakeCurrent(_hdc, null);
        delete _context;
        ReleaseDC(cast(HANDLE)handle, cast(HDC)_hdc);
        super.onHandleDestroyed(ea);
    }
    
    protected void setupPixelFormat() {
        int n;
        
        PIXELFORMATDESCRIPTOR pfd;
        
        pfd.nSize = pfd.sizeof;
        pfd.nVersion = 1;
        pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
        pfd.iPixelType = PFD_TYPE_RGBA;
        pfd.cColorBits = 24;
        pfd.cAlphaBits = 8;
        pfd.cAccumBits = 0;
        pfd.cDepthBits = 32;
        pfd.cStencilBits = 8;
        pfd.cAuxBuffers = 0;
        pfd.iLayerType = PFD_MAIN_PLANE;
        
        n = ChoosePixelFormat(
			cast(HANDLE) _hdc,
			cast(PIXELFORMATDESCRIPTOR*) &pfd
		);
        
        SetPixelFormat(cast(HANDLE) _hdc, n, &pfd);
    }

    protected void initGL() { }
    protected void render() { swapBuffers(); }

    override void onResize(EventArgs ea) {
        glViewport(0, 0, bounds.width, bounds.height);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
    }

    override void onPaint(PaintEventArgs pea) {
        super.onPaint(pea);
        render();
    }
    
    override void onPaintBackground(PaintEventArgs pea) { }
    void swapBuffers() { SwapBuffers(_hdc); }
    void makeCurrent()  {
		assert(_context !is null);
		_context.makeCurrent(this);
	}
}


class GLContext {
    protected HGLRC _hrc;
    
    this(GLControl glctrl, GLContext share_with = null) {
        _hrc = wglCreateContext(glctrl._hdc);
        if (share_with) wglShareLists( share_with._hrc, _hrc );
    }

    ~this() {
        wglDeleteContext(_hrc);
    }

    void makeCurrent(GLControl win) {
		//writefln("makeCurrent");
		if (wglMakeCurrent(win._hdc, _hrc)) return;
		//writefln("GLERROR: '%s'", sysErrorString(GetLastError()));
		throw new Exception(std.string.format("GLContext: wglMakeCurrent: '%s'", sysErrorString(GetLastError())));
    }
	
	static void release() {
		wglMakeCurrent(null, null);
	}
}