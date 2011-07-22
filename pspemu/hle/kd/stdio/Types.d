module pspemu.hle.kd.stdio.Types;

public import pspemu.hle.kd.Types;

enum : SceUID {
	STDIN  = -1,
	STDOUT = -2,
	STDERR = -3
}

