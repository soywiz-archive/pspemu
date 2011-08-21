module gdb.GdbServerConnectionBase;

import gdb.Sigval;
import gdb.GdbProcessorRegisters;

import std.string;
import std.conv;
import std.stdio;

ubyte[] TA(T)(ref T v) {
	return cast(ubyte[])((&v)[0..1]);
}

class GdbServerConnectionBase {
	bool debugFlag = true;
	Sigval lastSigval = Sigval.Ok;
	
	bool running = false;
	int[] threads = [100, 200, 311];
	int threadCursor;
	GdbProcessorRegisters registers;
	
	bool debugData;
	bool debugMaster = false;
	
	this() {
		init();
	}
	
	void init() {
		foreach (k, ref register; registers.ALL) register = k;
	}
	
	ubyte checksum(string text) {
		ubyte checksum = 0;
		foreach (c; text) checksum += c;
		return checksum;
	}
	
	// http://www.embecosm.com/appnotes/ean4/html/ch04s05s03.html
	string generatePacketWithChecksum(string packet) {
		return std.string.format("$%s#%02x", packet, checksum(packet));
	}
	
	void sendPacket(string packet) {
		
	}
	
	void sendPacketf(T...)(T args) {
		sendPacket(std.string.format(args));
	}
	
	void handlePacket(string packet) {
		string responsePacket = "E00";
		try {
			try {
				responsePacket = handlePacket2(packet);
			} catch (Throwable e) {
				responsePacket = "E01";
				throw(e);			
			}
		} finally {
			sendPacket(responsePacket);
		}
	}
	
	int hexDigitDecode(char hexDigit) {
		if (hexDigit >= '0' && hexDigit <= '9') return hexDigit - '0';
		if (hexDigit >= 'a' && hexDigit <= 'f') return hexDigit - 'a' + 10;
		if (hexDigit >= 'A' && hexDigit <= 'F') return hexDigit - 'A' + 10;
		return 0;
	}
	
	string hexEncode(ubyte[] data) {
		string r = "";
		foreach (c; data) r ~= std.string.format("%02x", c);
		return r;
	}
	
	ubyte[] hexDecode(string hexString) {
		ubyte[] r = [];
		for (int n = 0; n < hexString.length; n += 2) {
			r ~= cast(ubyte)(
				(hexDigitDecode(hexString[n + 0]) << 4) |
				(hexDigitDecode(hexString[n + 1]) << 0)
			);
		}
		return r;
	}
	
	string getSigvalPacket() {
		if (lastSigval == Sigval.Ok) return "T00";
		return std.string.format("S%02x", lastSigval);
	}
	
	string handlePacket2(string packet) {
		//string[] parts = std.array.split(";", packet);
		char type = packet[0];
		
		if (type != 'm') {
			if (debugMaster) {
				writefln("recvData: %s", packet);
			}
			debugData = true;
		} else {
			debugData = false;
		}
		
		switch (type) {
			// A simple reply of "OK" indicates the target will support extended remote debugging.
			case '!':
				return "OK";
			break;
			// The detach is acknowledged with a reply packet of "OK" before the client
			// connection is closed and rsp.client_fd set to -1. The semantics of detach
			// require the target to resume execution, so the processor is unstalled
			// using set_stall_state (0).
			case 'D':
				return "OK";
			break;
			// This sets the thread number of subsequent operations.
			// Since thread numbers are of no relevance to this target,
			// a response of "OK" is always acceptable.
			case 'H':
				return "OK";
			break;
			// The kill request is used in extended mode before a restart or
			// request to run a new program (vRun packet). Since the CPU is
			// already stalled, it seems to have no additional semantic meaning.
			// Since it requires no reply it can be silently ignored.
			case 'k':
				return "OK";
			break;
			// Since this is a bare level target, there is no concept of separate threads.
			// The one thread is always active, so a reply of "OK" is always acceptable.
			case 'T':
				return "OK";
			break;
			// The response to the ? packet is provided by rsp_report_exception ().
			// This is always a S packet. The signal value (as a GDB target signal)
			// is held in rsp.sigval, and is presented as two hexadecimal digits.
			case '?':
				if (running) {
					return getSigvalPacket();
				} else {
					return "E01";
				}
			break;
			case 'd':
				debugFlag = !debugFlag;
				return "OK";
			break;
			
			// Read all registers
			case 'g': {
				string o = "";
				foreach (n, register; registers.ALL) {
					o ~= hexEncode(TA(register));
				}
				return o;
			} break;
			// Write all registers
			case 'G':
			break;
			
			// Read a register
			case 'p': {
				int regNum = std.conv.parse!(uint)(packet[1..$], 16);
				return hexEncode(TA(registers.ALL[regNum]));
			} break;
			// Write a register
			case 'P': {
				string[] parts = std.string.split(packet[1..$], "=");
				auto regNum = std.conv.parse!(uint)(parts[0], 16);
				auto value = *cast(uint *)(hexDecode(parts[1]).ptr);
				registers.ALL[regNum] = value; 
				return "OK";
			} break;
			
			// http://www.embecosm.com/appnotes/ean4/html/ch04s07s07.html
			
			// Read from memory
			case 'm': {
				string[] parts = std.string.split(packet[1..$], ",");
				auto addr = std.conv.parse!(uint)(parts[0], 16);
				auto size = std.conv.parse!(uint)(parts[1], 16);
				ubyte[] data = new ubyte[size];
				data[] = 0xFF;
				return hexEncode(data);
			} break;
			// Write to memory
			case 'M':
			break;

			// The functionality for the R packet is provided in rsp_restart ().
			// The start address of the current target is held in rsp.start_addr.
			// The program counter is set to this address using set_npc () (see Section 4.6.5).
			case 'R':
			break;

			// Continue
			case 'c': {
				//scope (exit) lastSigval = Sigval.Ok;
				lastSigval = Sigval.DebugException;
				return getSigvalPacket();
				
				/*
				(new Thread({
					Thread.sleep(dur!"msecs"(400));
					lastSigval = Sigval.DebugException; 
					sendPacket(getSigvalPacket());
				})).start();

				lastSigval = Sigval.DebugException; 
				sendPacket(getSigvalPacket());
				
				return "";
				*/
				//return "";
			}

			// Step
			case 's':
				return "T00";
			break;

			// Extended packets.
			case 'v': {
				string[] packetParts = std.string.split(packet, ";");
				switch (packetParts[0]) {
					case "vRun": {
						string[] args;
						foreach (argHex; packetParts[1..$]) {
							args ~= cast(string)hexDecode(argHex);
						}
						writefln("%s", args);
						scope (exit) lastSigval = Sigval.InvalidOpcode;
						return "S00";
						//return getSigvalPacket();
						//return "";
					} break;
					case "vAttach":
					break;
					case "vCont":
					break;
					case "vCont?":
						return "OK";
					break;
					case "vFile":
					break;
					case "vFlashErase", "vFlashWrite", "vFlashDone":
					break;
					default:
						throw(new Exception(std.string.format("Unknown packet '%s'", packet)));
				}
			} break;
			
			// Query.
			// http://www.manpagez.com/info/gdb/gdb_282.php
			case 'q':
				string getNextThread(int cursor) {
					if (threadCursor >= threads.length) {
						return "l";
					} else {
						return std.string.format("m%x", threads[threadCursor]);
					}
				}
			
				switch (packet) {
					case "qfThreadInfo":
						threadCursor = 0;
						return getNextThread(threadCursor++);
					break;
					case "qsThreadInfo":
						return getNextThread(threadCursor++);
					break;
					case "qC":
						return std.string.format("QC%x", threads[0]);
					break;
					default:
						throw(new Exception(std.string.format("Unknown packet '%s'", packet)));
				}
			break;
			default:
				throw(new Exception(std.string.format("Unknown packet '%s'", packet[0])));
		}
		
		return "E01";
	}
}
