module pspemu.interfaces.IDisplay;

public import pspemu.interfaces.IComponent;
public import pspemu.hle.kd.display.Types;

interface IDisplay : IComponent {
	@property public uint currentVblankCount();
	public void sceDisplaySetMode(int mode = 0, int width = 480, int height = 272);
	public void sceDisplaySetFrameBuf(uint topaddr, uint bufferwidth, PspDisplayPixelFormats pixelformat, PspDisplaySetBufSync sync);
}