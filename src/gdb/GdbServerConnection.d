module gdb.GdbServerConnection;

import gdb.GdbServerConnectionBase;
import std.stream;
import std.stdio;

class GdbServerConnection : GdbServerConnectionBase {
	Stream outputStream;
	
	this(Stream outputStream) {
		this.outputStream = outputStream;
		super();
	}
	
	void sendPacket(string packet) {
		string sendPacket = generatePacketWithChecksum(packet);
		
		if (debugData) {
			writefln("sendData: +%s", sendPacket);
		}
		
		outputStream.write(cast(ubyte)'+');
		outputStream.write(cast(ubyte[])sendPacket);
		outputStream.flush();
	}
	
	ubyte[] bufferedData;
	
	void handleRawPacket(ubyte[] data) {
		while (data[0] == '+') data = data[1..$];
		if (data[$ - 3] != '#') {
			writefln("(2)'%s'", cast(string)data);
			throw(new Exception("Invalid exception"));
		}
		if (data[0] != '$') {
			writefln("(1)'%s'", cast(string)data);
			throw(new Exception("Invalid exception"));
		}
		// @TODO: Check checksum. Not useful on a TCP.
		handlePacket(cast(string)data[1..$ - 3]);
	}
	
	void handleRawData(ubyte[] data) {
		bufferedData ~= data;
		
		if (bufferedData.length >= 2 && bufferedData[1] == 3) {
			outputStream.close();
		}
		
		for (int n = 0; n < bufferedData.length; n++) {
			if (bufferedData[n] == '#') {
				try {
					handleRawPacket(bufferedData[0..n + 3]);
				} finally {
					bufferedData = bufferedData[n + 3..$];
					n = 0;
				}
			}
		}
	}
}