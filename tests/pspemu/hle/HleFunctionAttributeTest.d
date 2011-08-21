module pspemu.hle.HleFunctionAttributeTest;

import pspemu.hle.HleFunctionAttribute;
import pspemu.hle.HleModule;

import tests.Test;

class HleFunctionAttributeTest : Test {
	mixin TRegisterTest;

	void testCompiles() {
		//TestModule testModule = new TestModule();
		//testModule.initNids();
		assertSuccess();
	}
}

class TestModule : HleModule {
	alias HleFunctionAttribute HLE_FA;
	
	static string registerFunction(uint nid, alias func, uint requiredFirmwareVersion)() {
		return "";
	}
	
	void initNids() {
		mixin(HleFunctionAttribute.registerNids!TestModule);
	}

	mixin(HLE_FA(0x00000001, 150)); int c_method1() {
		return 1;
	}

	mixin(HLE_FA(0x00000002, 150)); int b_method2() {
		return 2;
	}

	mixin(HLE_FA(0x00000003, 150)); int a_method3() {
		return 3;
	}
}
