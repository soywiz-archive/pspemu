module pspemu.hle.HleModuleMethodBridgeGeneratorTest;

import pspemu.hle.HleModuleMethodBridgeGenerator;

import tests.Test;

void func001(int value) {
}

int func002(string str) {
	return 0;
}

void func003(int v1, int v2) {
}

void func004(int v1, long v2) {
}

void func005(int v1, int v2, long v3) {
}

class HleModuleMethodBridgeGeneratorTest : Test {
	void testGenerate() {
		assertEquals(
			"{this.func001(cast(int)param(0));}",
			HleModuleMethodBridgeGenerator.getCall!(func001),
		);
		assertEquals(
			"{auto retval = this.func002(paramsz(0));currentRegisters.V0 = (cast(uint *)&retval)[0];}",
			HleModuleMethodBridgeGenerator.getCall!(func002)
		);
		assertEquals(
			"{this.func003(cast(int)param(0), cast(int)param(1));}",
			HleModuleMethodBridgeGenerator.getCall!(func003)
		);
		assertEquals(
			"{this.func004(cast(int)param(0), cast(long)param64(2));}",
			HleModuleMethodBridgeGenerator.getCall!(func004)
		);
		assertEquals(
			"{this.func005(cast(int)param(0), cast(int)param(1), cast(long)param64(2));}",
			HleModuleMethodBridgeGenerator.getCall!(func005)
		);
	}
}