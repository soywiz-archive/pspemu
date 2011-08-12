module pspemu.hle.HleThreadManagerTest;

import pspemu.hle.HleThreadManager;
import pspemu.hle.HleThreadBase;

import tests.Test;

class HleThreadMock : HleThreadBase {
	int resumedCount;
	int value;
	int priority;
	
	alias void delegate(HleThreadMock) Emit; 
	
	Emit emit;
	
	this(Emit emit, int value, int priority = 10) {
		this.emit = emit;
		this.value = value;
		this.priority = priority;
	}
	
	public void threadResume() {
		resumedCount++;
		this.emit(this);
	}

	public @property int currentPriority() {
		return priority;
	}
	
	public @property bool threadFinished() {
		return (resumedCount > 3);
	}
}

class HleThreadManagerTest : Test {
	HleThreadManager hleThreadManager;
	HleThreadMock thread1;
	HleThreadMock thread2;
	
	void setUp() {
		hleThreadManager = new HleThreadManager();
	}
	
	void testScheduling() {
		int[] values;
		
		void emit(HleThreadMock hleThreadMock) {
			values ~= hleThreadMock.value;
		}
		
		hleThreadManager.add(thread1 = new HleThreadMock(&emit, 1, 10));
		hleThreadManager.add(thread2 = new HleThreadMock(&emit, 2,  5));
		hleThreadManager.executionLoop();
		
		assertEquals(
			"[2,1,2,2,1,2,1,1]",
			std.string.format("%s", values),
		);
	}
}