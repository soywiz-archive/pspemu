module dfl.ext.DrawingArea;

import dfl.all;
import dfl.internal.winapi;
import dfl.ext.DirectBitmap;
import dfl.ext.graphicsbuffer;


class DrawingArea : PictureBox {
	Pixel         clearColor;
	DirectBitmap  dbmp;
	bool          drawable = false;

	this(uint width, uint height, uint componentWidth, uint componentHeight) {
		super();
		setStyle(ControlStyles.OPAQUE, true);
		
		clearColor.r = clearColor.g = clearColor.b = 20;

		dbmp = new DirectBitmap(width, height, Graphics.getScreen.handle);
		dbmp.lock()[] = clearColor;
		dbmp.unlock();

		//sizeMode = PictureBoxSizeMode.AUTO_SIZE;
		sizeMode = PictureBoxSizeMode.STRETCH_IMAGE;
		image = dbmp;
	}

	this(uint width, uint height) {
		this(width, height, width, height);
	}
	
	
	void clear() {
		dbmp.lock()[] = clearColor;
		dbmp.unlock();
		invalidate();
	}
	
	final void brushPaint(uint X, uint Y, int size, Pixel color, Pixel[] pixels) {
		void putPixel(uint x, uint y, Pixel pix) {
			if (x < dbmp.width && y < dbmp.height) {
				pixels[dbmp.width * (dbmp.height - y - 1) + x] = pix;
			}
		}
		
		for (int y = -size; y <= size; ++y) {
			for (int x = -size; x <= size; ++x) {
				if (x*x + y*y <= size*(size+1)) {
					putPixel(X+x, Y+y, color);
				}
			}
		}
	}
	
	
	void blur(int size=1) {
		Pixel[]	pixels	= dbmp.lock();
		Pixel[]	blurred	= new Pixel[pixels.length];
		
		for (int y = 0; y < height; ++y) {
			for (int x = 0; x < width; ++x) {
				uint cnt, r, g, b;
				
				void add(int cx, int cy) {
					if (cx >= 0 && cx < width && cy >= 0 && cy < height) {
						++cnt;
						Pixel pix = pixels[cx + cy*width];
						r += pix.r;
						g += pix.g;
						b += pix.b;
					}
				}
				
				for (int cx = -size; cx <= size; ++cx) {
					for (int cy = -size; cy <= size; ++cy) {
						if (cx*cx+cy*cy <= size+1) {
							add(x+cx, y+cy);
						}
					}
				}
				
				r /= cnt;
				g /= cnt;
				b /= cnt;
				
				Pixel* pix = &blurred[x + y*width];
				pix.r = cast(ubyte)r;
				pix.g = cast(ubyte)g;
				pix.b = cast(ubyte)b;
			}
		}
		
		pixels[] = blurred[];
		dbmp.unlock();
	}
	
	
	void mouseDraw(MouseEventArgs args) {
		if (args.button & (MouseButtons.LEFT | MouseButtons.RIGHT)) {
			Pixel[] pixels = dbmp.lock();
			
			Pixel color;
			int brushsize;
			
			if (args.button & MouseButtons.LEFT) {
				color.r = 230;
				color.g = 230;
				color.b = 230;
				brushsize = 4;
			} else {
				color.r = 20;
				color.g = 20;
				color.b = 20;
				brushsize = 10;
			}
			
			brushPaint(args.x, args.y, brushsize, color, pixels);
			
			dbmp.unlock();
			invalidate();
		}
	}
	
	override void onMouseDown(MouseEventArgs args) {
		super.onMouseDown(args);
		if (drawable) mouseDraw(args);
	}
	
	
	void _invalidate() {
		RECT r;
		displayRectangle.getRect(&r);
		InvalidateRect(handle, &r, false);
	}
	
	
	override void onMouseMove(MouseEventArgs args) {
		super.onMouseMove(args);
		if (drawable) mouseDraw(args);
	}
}
