module gdb.GdbServer;

import gdb.TcpServer;
import gdb.GdbServerConnection;

import std.stream;
import std.socket;
import std.socketstream;

// http://www.embecosm.com/appnotes/ean4/html/ch04s07s03.html
// gdb/m32r-stub.c
class GdbServer : TcpServer {
	GdbServerConnection[Socket] clientBySocket;
	
	this() {
		//super("127.0.0.1", 16728);
		super("127.0.0.1", 23946);
	}
	
	void handleConnect(Socket socket) {
		super.handleConnect(socket);
		clientBySocket[socket] = new GdbServerConnection(new SocketStream(socket, FileMode.Out));
	}
	
	void handleData(Socket socket, ubyte[] data) {
		//super.handleData(socket, data);
		clientBySocket[socket].handleRawData(data);
	}
	
	void handleDisconnect(Socket socket) {
		super.handleDisconnect(socket);
		clientBySocket.remove(socket);
	}
}
