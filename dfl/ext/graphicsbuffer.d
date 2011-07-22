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
module dfl.ext.graphicsbuffer;


private import std.intrinsic;

private import dfl.all, dfl.internal.winapi;


const int GRAPHICS_BUFFER_MINIMUM_SIZE = 256;
const int GRAPHICS_BUFFER_AUTO_GAIN = 50;


private uint _round2power(uint x)
{
	if(!x)
		return 1;
	uint z = 1 << std.intrinsic.bsr(x);
	if(x == z)
		return x;
	return z << 1;
}


/// Resizable graphics buffer.
struct ResizableGraphicsBuffer
{
	/// Start the graphics buffer with its initialial dimensions. The initial bits of the graphics buffer are undefined.
	void start(int width, int height)
	{
		assert(gbuf is null);
		rwidth = width;
		rheight = height;
		_bestSize(width, height);
		gbuf = new MemoryGraphics(width, height);
	}
	
	
	/// ditto
	void start(Size size)
	{
		return start(size.width, size.height);
	}
	
	
	/// Get the graphics buffer's Graphics to draw on.
	Graphics graphics() // getter
	{
		return gbuf;
	}
	
	
	/// Copy the graphics buffer bits to the provided Graphics.
	bool copyTo(Graphics g)
	{
		return gbuf.copyTo(g, 0, 0, rwidth, rheight);
	}
	
	
	/// ditto
	bool copyTo(Graphics g, Rect clipRect)
	{
		return gbuf.copyTo(g, clipRect.x, clipRect.y, clipRect.width, clipRect.height,
			clipRect.x, clipRect.y);
	}
	
	
	/// Stop the graphics buffer by releasing resources.
	void stop()
	{
		if(gbuf)
		{
			gbuf.dispose();
			gbuf = null;
		}
	}
	
	
	/// Update the dimensions of the graphics buffer.
	/// Returns: true if the entire area needs to be redrawn and the bits of the graphics buffer are undefined.
	bool resize(int width, int height)
	{
		rwidth = width;
		rheight = height;
		
		if(rwidth > gbuf.width || rheight > gbuf.height)
		{
			_bestSize(width, height);
			_resize(width, height);
			return true;
		}
		
		if(rwidth < (gbuf.width >> 1) - (gbuf.width >> 3) || rheight < (gbuf.height >> 1) - (gbuf.height >> 3))
		{
			_bestSize(width, height);
			if(width < gbuf.width || height < gbuf.height)
			{
				_resize(width, height);
				return true;
			}
		}
		
		return false;
	}
	
	
	/// ditto
	void resize(Size size)
	{
		return resize(size.width, size.height);
	}
	
	
	/// Property: get the graphics buffer.
	Graphics graphicsBuffer() // getter
	{
		return gbuf;
	}
	
	
	/// Property: get the dimensions of the graphics buffer.
	int width() // getter
	{
		return rwidth;
	}
	
	
	/// ditto
	int height() // getter
	{
		return rheight;
	}
	
	
	/// ditto
	Size size() // getter
	{
		return Size(rwidth, rheight);
	}
	
	
	private:
	int rwidth, rheight;
	MemoryGraphics gbuf = null;
	
	
	void _bestSize(ref int width, ref int height)
	{
		width += GRAPHICS_BUFFER_AUTO_GAIN;
		height += GRAPHICS_BUFFER_AUTO_GAIN;
		
		if(width <= GRAPHICS_BUFFER_MINIMUM_SIZE)
			width = GRAPHICS_BUFFER_MINIMUM_SIZE;
		else
			width = _round2power(width);
		
		if(height <= GRAPHICS_BUFFER_MINIMUM_SIZE)
			height = GRAPHICS_BUFFER_MINIMUM_SIZE;
		else
			height = _round2power(height);
	}
	
	
	void _resize(int width, int height)
	{
		gbuf.dispose();
		gbuf = new MemoryGraphics(width, height);
	}
}


/// Mixin for a fixed-size, double buffer Control. ControlStyles ALL_PAINTING_IN_WM_PAINT and USER_PAINT must be set.
template ControlFixedGraphicsBuffer()
{
	protected override void onPaint(PaintEventArgs ea)
	{
		if(!_dbuf)
		{
			_dbuf = new MemoryGraphics(clientSize.width, clientSize.height, ea.graphics);
			auto PaintEventArgs superea = new PaintEventArgs(_dbuf, Rect(0, 0, clientSize.width, clientSize.height));
			onBufferPaint(superea);
			_dbuf.copyTo(ea.graphics);
		}
		else
		{
			_dbuf.copyTo(ea.graphics, ea.clipRectangle.x, ea.clipRectangle.y, ea.clipRectangle.width, ea.clipRectangle.height,
				ea.clipRectangle.x, ea.clipRectangle.y);
		}
	}
	
	
	protected final void onPaintBackground(PaintEventArgs ea)
	{
	}
	
	
	/// Override to draw onto the graphics buffer.
	protected void onBufferPaint(PaintEventArgs ea)
	{
		super.onPaintBackground(ea);
	}
	
	
	/// Updates the double buffer by calling onBufferPaint() and fires a screen-redraw event.
	void updateGraphics(Rect area)
	{
		if(_dbuf)
		{
			auto PaintEventArgs superea = new PaintEventArgs(_dbuf, area);
			onBufferPaint(superea);
		}
		invalidate(area);
	}
	
	
	/// ditto
	void updateGraphics()
	{
		return updateGraphics(Rect(0, 0, clientSize.width, clientSize.height));
	}
	
	
	/// Property: get the graphics buffer. May be null if there is no need for a graphics buffer yet.
	/// invalidate() can be used to fire a screen-redraw event.
	Graphics graphicsBuffer() // getter
	{
		return _dbuf;
	}
	
	
	///
	override void dispose()
	{
		super.dispose();
		if(_dbuf)
			_dbuf.dispose();
	}
	
	
	private:
	MemoryGraphics _dbuf = null;
}


/// Mixin for a variable-size, double buffer Control. ControlStyles ALL_PAINTING_IN_WM_PAINT and USER_PAINT must be set.
template ControlResizableGraphicsBuffer()
{
	protected final void onPaint(PaintEventArgs ea)
	{
		if(!_gbuf.graphics)
		{
			_gbuf.start(clientSize.width, clientSize.height);
			scope PaintEventArgs superea = new PaintEventArgs(_gbuf.graphics, Rect(0, 0, clientSize.width, clientSize.height));
			onBufferPaint(superea);
			_gbuf.copyTo(ea.graphics);
		}
		else
		{
			_gbuf.copyTo(ea.graphics, ea.clipRectangle);
		}
	}
	
	
	protected final void onPaintBackground(PaintEventArgs ea)
	{
	}
	
	
	/// Override to draw onto the graphics buffer.
	protected void onBufferPaint(PaintEventArgs ea)
	{
		super.onPaintBackground(ea);
	}
	
	
	protected override void onResize(EventArgs ea)
	{
		super.onResize(ea);
		
		static if(is(typeof(this) : Form))
		{
			if(FormWindowState.MINIMIZED == windowState)
			{
				//printf("minimize\n");
				return;
			}
		}
		
		if(_gbuf.graphics)
		{
			if(_gbuf.resize(clientSize.width, clientSize.height))
			{
				//printf("resize\n");
			}
			
			if(_gbuf.graphics)
			{
				scope PaintEventArgs superea = new PaintEventArgs(_gbuf.graphics, Rect(0, 0, clientSize.width, clientSize.height));
				onBufferPaint(superea);
			}
		}
		invalidate();
	}
	
	
	/// Updates the double buffer by calling onBufferPaint() and fires a screen-redraw event.
	void updateGraphics(Rect area)
	{
		if(_gbuf.graphics)
		{
			scope PaintEventArgs superea = new PaintEventArgs(_gbuf.graphics, area);
			onBufferPaint(superea);
		}
		invalidate(area);
	}
	
	
	/// ditto
	void updateGraphics()
	{
		return updateGraphics(Rect(0, 0, clientSize.width, clientSize.height));
	}
	
	
	/// Property: get the graphics buffer. May be null if there is no need for a graphics buffer yet.
	/// invalidate() can be used to fire a screen-redraw event.
	Graphics graphicsBuffer() // getter
	{
		return _gbuf.graphicsBuffer;
	}
	
	
	///
	override void dispose()
	{
		super.dispose();
		_gbuf.stop();
	}
	
	
	private:
	ResizableGraphicsBuffer _gbuf;
}


/// Mixes in ControlResizableGraphicsBuffer and sets the appropriate styles.
/+++
Example:
---
private import dfl.all
private import graphicsbuffer;

class MyForm: DoubleBufferedForm
{
	protected override void onBufferPaint(PaintEventArgs ea)
	{
		super.onBufferPaint(ea); // Fills the background color.
		
		// Other painting and drawing to ea.graphics...
	}
}

void main()
{
	Application.run(new MyForm());
}
---
+/
class DoubleBufferedForm: Form
{
	mixin ControlResizableGraphicsBuffer; ///
	
	
	this()
	{
		setStyle(ControlStyles.ALL_PAINTING_IN_WM_PAINT | ControlStyles.USER_PAINT, true);
	}
}


/// Mixes in ControlResizableGraphicsBuffer and sets the appropriate styles.
class DoubleBufferedControl: UserControl
{
	mixin ControlResizableGraphicsBuffer; ///
	
	
	this()
	{
		setStyle(ControlStyles.ALL_PAINTING_IN_WM_PAINT | ControlStyles.USER_PAINT, true);
	}
}


/+ // Test
int main()
{
	Application.run(new DoubleBufferedForm);
	return 0;
}
+/

