module gdb.TcpServer;

import std.stdio;
import std.socket;
import core.thread;

class TcpServer {
	TcpSocket serverSocket;
	string ip;
	short port;
	bool[Socket] clients;
	SocketSet checkRead, checkWrite, checkError;
	
	this(string ip, short port) {
		this.ip = ip;
		this.port = port;
		this.serverSocket = new TcpSocket();
		this.serverSocket.blocking = false;
		this.checkRead = new SocketSet();
		this.checkWrite = new SocketSet();
		this.checkError = new SocketSet();
	}
	
	void listen(int backlog = 16) {
		writef("Starting server %s:%d...", ip, port);
		serverSocket.bind(new InternetAddress(ip, port));
		serverSocket.listen(backlog);
		writefln("Ok");
		
		while (true) {
			checkRead.reset();
			checkWrite.reset();
			checkError.reset();
			
			checkRead.add(serverSocket);
			checkWrite.add(serverSocket);
			checkError.add(serverSocket);
			
			foreach (ref clientSocket; clients.keys) {
				checkRead.add(clientSocket);
				//checkWrite.add(clientSocket);
				checkError.add(clientSocket);
			}
			
			serverSocket.select(checkRead, checkWrite, checkError);
			
			// New connection available.
			if (checkRead.isSet(serverSocket)) {
				Socket clientSocket = serverSocket.accept();
				clientSocket.blocking = false;
				clients[clientSocket] = true;
				try {
					handleConnect(clientSocket);
				} catch (Throwable o) {
					writefln("%s", o);
				}
			}
			
			foreach (ref clientSocket; clients.keys.dup) {
				// Data available.
				if (checkRead.isSet(clientSocket)) {
					ubyte[] buffer = new ubyte[1024];
					int bufferLen;
					while (true) {
						bufferLen = clientSocket.receive(buffer);
						if (bufferLen <= 0) break;
						try {
							handleData(clientSocket, buffer[0..bufferLen]);
						} catch (Throwable o) {
							writefln("%s", o);
						}
					}
					if (bufferLen == 0) {
						clients.remove(clientSocket);
						try {
							handleDisconnect(clientSocket);
						} catch (Throwable o) {
							writefln("%s", o);
						}
					}
				}
			}
			
			Thread.sleep(dur!"msecs"(1));
		}
	}
	
	void handleConnect(Socket socket) {
		writefln("onConnect: %s", socket);
	}
	
	void handleData(Socket socket, ubyte[] data) {
		writefln("onData: %s : %s : %s", socket, data, cast(string)data);
	}
	
	void handleDisconnect(Socket socket) {
		writefln("onDisconnect: %s", socket);
	}
}