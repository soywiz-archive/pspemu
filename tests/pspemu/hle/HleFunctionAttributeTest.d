module pspemu.hle.HleFunctionAttributeTest;

import pspemu.hle.HleFunctionAttribute;
import pspemu.hle.HleModule;

import tests.Test;

class TestModule : HleModule {
	static string registerd(uint nid, alias func, uint requiredFirmwareVersion)() {
		return "";
	}
	
	void initNids() {
		mixin(HleFunctionAttribute.registerNids);
	}

	/* @ */ mixin(HleFunctionAttribute(NID(0x00000001), MIN_FW(150)));
	int c_method1() {
		return 1;
	}

	/* @ */ mixin(HleFunctionAttribute(NID(0x00000002), MIN_FW(150)));
	int b_method2() {
		return 2;
	}

	/* @ */ mixin(HleFunctionAttribute(NID(0x00000003), MIN_FW(150)));
	int a_method3() {
		return 3;
	}
}

class HleFunctionAttributeTest : Test {
	void testCompiles() {
		//TestModule testModule = new TestModule();
		//testModule.initNids();
		assertSuccess();
	}
}