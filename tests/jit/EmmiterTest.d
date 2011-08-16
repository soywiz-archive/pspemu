module jit.EmmiterTest;

import std.stdio;

import jit.Emmiter;

import tests.Test;

class EmmiterTest : Test {
	Emmiter emmiter;
	
	void setUp() {
		emmiter = new EmmiterLittleEndian();
	}
	
	void testCantWriteAfterFinalize() {
		emmiter.write1(1);
		emmiter.write1(2);
		emmiter.finalize();
		expectException!Exception({
			emmiter.write1(3);
		});
	}
	
	void testEmitLittleEndian() {
		scope Emmiter emmiterLE = new EmmiterLittleEndian();
		emmiterLE.write1(1);
		emmiterLE.write4(-2);
		assertEquals([1, 254, 255, 255, 255], emmiterLE.finalize());
	}

	void testEmitBigEndian() {
		scope Emmiter emmiterBE = new EmmiterBigEndian();
		emmiterBE.write1(1);
		emmiterBE.write4(-2);
		assertEquals([1, 255, 255, 255, 254], emmiterBE.finalize());
	}
	
	void testLabelBlockRelative() {
		Emmiter.Label startLabel, middleLabel, endLabel;
		emmiter.setLabelHere(startLabel);
		emmiter.write1(1);
		emmiter.writeLabelBlockRelative4(middleLabel);
		emmiter.setLabelHere(middleLabel);
		emmiter.writeLabelBlockRelative4(endLabel);
		emmiter.write1(2);
		emmiter.writeLabelBlockRelative4(startLabel);
		emmiter.setLabelHere(endLabel);
		assertEquals([1, 5, 0, 0, 0, 14, 0, 0, 0, 2, 0, 0, 0, 0], emmiter.finalize());
	}
	
	void testLabelRelative() {
		Emmiter.Label startLabel, middleLabel, endLabel;
		emmiter.setLabelHere(startLabel);
		emmiter.write1(1);
		emmiter.writeLabelRelative4(middleLabel);
		emmiter.setLabelHere(middleLabel);
		emmiter.writeLabelRelative4(endLabel);
		emmiter.write1(2);
		emmiter.writeLabelRelative4(startLabel);
		emmiter.setLabelHere(endLabel);
		assertEquals([1, 4, 0, 0, 0, 9, 0, 0, 0, 2, 246, 255, 255, 255], emmiter.finalize());
	}
}