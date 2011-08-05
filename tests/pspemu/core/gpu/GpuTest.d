module pspemu.core.gpu.GpuTest;

import pspemu.core.gpu.Gpu;

import tests.Test;

class GpuTest : Test {
	Gpu gpu;
	
	this() {
		gpu = new Gpu();
	}
	
	void testCantModify0() {
	}
}