module pspemu.core.gpu.GpuTest;

import pspemu.core.Memory;
import pspemu.core.gpu.Gpu;
import pspemu.core.gpu.impl.dummy.GpuImplDummy;

import tests.Test;

class GpuTest : Test {
	Memory memory;
	Gpu gpu;
	IGpuImpl gpuImpl;
	
	this() {
		memory = new Memory();
		gpuImpl = new GpuImplDummy();
		gpu = new Gpu(memory, gpuImpl);
	}
	
	void testCompile() {
		assertSuccess();
	}
}