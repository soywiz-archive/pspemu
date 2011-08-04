module pspemu.utils.net.SimpleHttp;

import std.stdio;
import std.conv;
import std.string;
import std.regex;
import std.stream;
import std.array;
import std.socket;
import std.socketstream;
import std.socketstream;

class SimpleHttp {
	struct UrlInfo {
		string schema;
		string host;
		string user;
		string password;
		string port;
		string path;
		string query;
		string hash;
		
		short portInt() {
			if (port.length) return to!short(port);
			switch (schema) {
				case "ftp": return 21;
				case "http": return 80;
				case "https": return 443;
				default: throw(new Exception(std.string.format("Unknown UrlInfo.schema '%s'", schema)));
			}
		}
		
		string fullPath() {
			return path ~ query;
		}
	}

	static UrlInfo parseUrl(string url) {
		UrlInfo urlInfo;
		scope m = match(
			url,
		    regex(
		    	r"^"
		    	r"(http|https|ftp|ftps)://" // schema
		    	r"([\w\.]+)"                 // host
		    	r"(:(80))?"                  // optional port
		    	r"(/[^\?]*)"
		    	r"(\?.+)?"
		    	r"$"
			)
		);
		if (m.empty) throw(new Exception(std.string.format("Can't parse url '%s'", url)));
		
		//int k = 0; foreach (s; m.captures) { writefln("%d: %s", k, s); k++; }
		
		urlInfo.schema   = m.captures[1];
		urlInfo.host     = m.captures[2];
		urlInfo.user     = "";
		urlInfo.password = "";
		urlInfo.port     = m.captures[4];
		urlInfo.path     = m.captures[5];
		urlInfo.query    = m.captures[6];
		urlInfo.hash     = "";

		return urlInfo;
	}
	
	static ubyte[] downloadFile(string url) {
		ubyte[] data = downloadFileWithHeaders(url);
		int index = std.string.indexOf(cast(char[])data, "\r\n\r\n");
		return data[index + 4..$];
	}
	
	static ubyte[] downloadFileWithHeaders(string url) {
		UrlInfo urlInfo = parseUrl(url);
		TcpSocket socket = new TcpSocket(AddressFamily.INET);
		InternetHost host = new InternetHost();
		host.getHostByName(urlInfo.host);
		InternetAddress address = new InternetAddress(host.addrList[0], urlInfo.portInt);
		socket.connect(address);
		SocketStream socketStream = new SocketStream(socket, FileMode.In | FileMode.Out);
		socketStream.writef("GET %s HTTP/1.1\r\n", urlInfo.fullPath);
		socketStream.writef("Host: %s\r\n", urlInfo.host);
		socketStream.writef("Connection: close\r\n");
		socketStream.writef("\r\n");
		ubyte[] data;
		ubyte[] temp = new ubyte[1024];
		while (!socketStream.eof) {
			int readed = socketStream.read(temp);
			data ~= temp[0..readed];
		}
		return data;
	}
}
