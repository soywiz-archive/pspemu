module gdb.GdbServerTest;

import gdb.GdbServer;
import gdb.GdbServerConnectionBase;
import gdb.IGdbProcessor;
import gdb.Sigval;

import tests.Test;

class GdbServerTest : Test {
	mixin TRegisterTest;
	
	class GdbServerConnectionBaseMock : GdbServerConnectionBase {
		void sendPacket(string packet) {
			output ~= packet;
		}
	}
	
	string[] output;
	GdbServerConnectionBaseMock gdbServer;
	
	void setUp() {
		output = [];
		gdbServer = new GdbServerConnectionBaseMock();
	}
	
	void testSupportExtended() {
		gdbServer.handlePacket("!");
		assertEquals(["OK"], output);
	}

	void test_QuestionMark() {
		gdbServer.handlePacket("?");
		assertEquals(["E01"], output);
	}
	
	void testListen() {
		//(new GdbServer()).listen();
	}
}

class GdbProcessor : IGdbProcessor {
	void registerOnSigval(void delegate(Sigval sigval) callback) {
		
	}

	uint getRegister(uint index) {
		return 0;
	}
	void setRegister(uint index, uint value) {
		
	}

	int  getMemoryRange(ubyte[] buffer) {
		return 0;
	}
	int  setMemoryRange(ubyte[] buffer) {
		return 0;
	}

	void run() {
		
	}	
	void stepInto() {
		
	}
	void stepOver() {
		
	}
	void pause() {
		
	}
	void stop() {
		
	}
	@property bool isRunning() {
		return false;
	}
}
