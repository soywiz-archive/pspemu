module pspemu.utils.imaging.SimpleTga;

align (1) struct TGA_HEADER {
    byte  identsize = 0;          // size of ID field that follows 18 byte header (0 usually)
    byte  colourmaptype = 0;      // type of colour map 0=none, 1=has palette
    byte  imagetype = 2;          // type of image 0=none,1=indexed,2=rgb,3=grey,+8=rle packed

    short colourmapstart = 0;     // first colour map entry in palette
    short colourmaplength = 0;    // number of colours in palette
    byte  colourmapbits = 0;      // number of bits per palette entry 15,16,24,32

    short xstart = 0;             // image x origin
    short ystart = 0;             // image y origin
    short width;              // image width in pixels
    short height;             // image height in pixels
    byte  bits = 32;               // image bits per pixel 8,16,24,32
    byte  descriptor = 0b00101111;         // image descriptor bits (vh flip bits)
    
    // pixel data follows header
}

/*
TGA_HEADER tgaHeader;
tgaHeader.width = cast(short)texture.getTextureWidth();
tgaHeader.height = cast(short)texture.getTextureHeight();
{
	scope tgaFile = new BufferedFile(std.string.format("TEXTURE_%08X_%s_%s.tga", texture.textureHash, to!string(texture.textureFormat), to!string(texture.clutFormat)), FileMode.OutNew);
	tgaFile.write(TA(tgaHeader));
	tgaFile.write(data);
	tgaFile.flush();
	tgaFile.close();
}
*/