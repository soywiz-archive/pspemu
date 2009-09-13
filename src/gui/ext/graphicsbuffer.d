/*
	Copyright (C) 2006 Christopher E. Miller
	
	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any damages
	arising from the use of this software.
	
	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:
	
	1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.
	2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.
	3. This notice may not be removed or altered from any source distribution.
*/

module dfl.graphicsbuffer;

private import std.intrinsic;
private import dfl.all, dfl.internal.winapi;

const int GRAPHICS_BUFFER_MINIMUM_SIZE = 256;
const int GRAPHICS_BUFFER_AUTO_GAIN = 50;

private uint _round2power(uint x) {
	if (!x) return 1;
	uint z = 1 << std.intrinsic.bsr(x);
	return (x == z) ? x : (z << 1);
}

struct ResizableGraphicsBuffer {
	void start(int width, int height) {
		assert(gbuf is null);
		rwidth = width;
		rheight = height;
		_bestSize(width, height);
		gbuf = new MemoryGraphics(width, height);
	}
	
	void start(Size size) { return start(size.width, size.height); }
	Graphics graphics() { return gbuf; }
	bool copyTo(Graphics g) { return gbuf.copyTo(g, 0, 0, rwidth, rheight); }
	bool copyTo(Graphics g, Rect clipRect) { return gbuf.copyTo(g, clipRect.x, clipRect.y, clipRect.width, clipRect.height, clipRect.x, clipRect.y); }
	void stop() { if (gbuf) { gbuf.dispose(); gbuf = null; } }
	bool resize(int width, int height) {
		rwidth = width;
		rheight = height;
		
		if (rwidth > gbuf.width || rheight > gbuf.height) {
			_bestSize(width, height);
			_resize(width, height);
			return true;
		}
		
		if (rwidth < (gbuf.width >> 1) - (gbuf.width >> 3) || rheight < (gbuf.height >> 1) - (gbuf.height >> 3)) {
			_bestSize(width, height);
			if (width < gbuf.width || height < gbuf.height) {
				_resize(width, height);
				return true;
			}
		}
		
		return false;
	}
	
	void resize(Size size) { return resize(size.width, size.height); }
	Graphics graphicsBuffer() { return gbuf; }
	int width() { return rwidth; }
	int height() { return rheight; }
	Size size() { return Size(rwidth, rheight); }
	
	private int rwidth, rheight;
	private MemoryGraphics gbuf = null;
	
	private void _bestSize(inout int width, inout int height) {
		width  += GRAPHICS_BUFFER_AUTO_GAIN;
		height += GRAPHICS_BUFFER_AUTO_GAIN;
		width = (width <= GRAPHICS_BUFFER_MINIMUM_SIZE) ? GRAPHICS_BUFFER_MINIMUM_SIZE : _round2power(width);
		height = (height <= GRAPHICS_BUFFER_MINIMUM_SIZE) ? GRAPHICS_BUFFER_MINIMUM_SIZE : _round2power(height);
	}

	private void _resize(int width, int height) {
		gbuf.dispose();
		gbuf = new MemoryGraphics(width, height);
	}
}

template ControlFixedGraphicsBuffer() {
	protected override void onPaint(PaintEventArgs ea) {
		if (!_dbuf) {
			_dbuf = new MemoryGraphics(clientSize.width, clientSize.height, ea.graphics);
			auto PaintEventArgs superea = new PaintEventArgs(_dbuf, Rect(0, 0, clientSize.width, clientSize.height));
			onBufferPaint(superea);
			_dbuf.copyTo(ea.graphics);
		} else {
			_dbuf.copyTo(ea.graphics, ea.clipRectangle.x, ea.clipRectangle.y, ea.clipRectangle.width, ea.clipRectangle.height, ea.clipRectangle.x, ea.clipRectangle.y);
		}
	}

	protected final void onPaintBackground(PaintEventArgs ea) { }
	protected void onBufferPaint(PaintEventArgs ea) { super.onPaintBackground(ea); }
	void updateGraphics(Rect area) {
		if (_dbuf) {
			auto PaintEventArgs superea = new PaintEventArgs(_dbuf, area);
			onBufferPaint(superea);
		}
		invalidate(area);
	}
	
	void updateGraphics() {
		return updateGraphics(Rect(0, 0, clientSize.width, clientSize.height));
	}
	
	Graphics graphicsBuffer() { return _dbuf; }
	override void dispose() { super.dispose(); if (_dbuf) _dbuf.dispose(); }
	
	private MemoryGraphics _dbuf = null;
}

template ControlResizableGraphicsBuffer() {
	protected final void onPaint(PaintEventArgs ea) {
		if (!_gbuf.graphics) {
			_gbuf.start(clientSize.width, clientSize.height);
			auto PaintEventArgs superea = new PaintEventArgs(_gbuf.graphics, Rect(0, 0, clientSize.width, clientSize.height));
			onBufferPaint(superea);
			_gbuf.copyTo(ea.graphics);
		} else {
			_gbuf.copyTo(ea.graphics, ea.clipRectangle);
		}
	}
	
	
	protected final void onPaintBackground(PaintEventArgs ea) { }
	protected void onBufferPaint(PaintEventArgs ea) { super.onPaintBackground(ea); }
	
	protected override void onResize(EventArgs ea) {
		super.onResize(ea);
		
		static if (is(typeof(this) : Form)) {
			if (FormWindowState.MINIMIZED == windowState) return;
		}
		
		if (_gbuf.graphics) {
			if (_gbuf.resize(clientSize.width, clientSize.height)) { }
			if (_gbuf.graphics) {
				auto PaintEventArgs superea = new PaintEventArgs(_gbuf.graphics, Rect(0, 0, clientSize.width, clientSize.height));
				onBufferPaint(superea);
			}
		}
		
		invalidate();
	}
	
	void updateGraphics(Rect area) {
		if (_gbuf.graphics) {
			auto PaintEventArgs superea = new PaintEventArgs(_gbuf.graphics, area);
			onBufferPaint(superea);
		}
		invalidate(area);
	}

	void updateGraphics() { return updateGraphics(Rect(0, 0, clientSize.width, clientSize.height)); }
	Graphics graphicsBuffer() { return _gbuf.graphicsBuffer; }
	override void dispose() { super.dispose(); _gbuf.stop(); }
	
	private ResizableGraphicsBuffer _gbuf;
}

class DoubleBufferedForm : Form {
	mixin ControlResizableGraphicsBuffer;
	this() { setStyle(ControlStyles.ALL_PAINTING_IN_WM_PAINT | ControlStyles.USER_PAINT, true); }
}

class DoubleBufferedControl : UserControl {
	mixin ControlResizableGraphicsBuffer;
	this() { setStyle(ControlStyles.ALL_PAINTING_IN_WM_PAINT | ControlStyles.USER_PAINT, true); }
}