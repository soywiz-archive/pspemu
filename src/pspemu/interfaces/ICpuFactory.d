module pspemu.interfaces.ICpuFactory;

import pspemu.interfaces.ICpu;

interface ICpuFactory {
	ICpu createICpuInstance();
}