module pspemu.core.cpu.assembler.CpuAssemblerUtils;

import std.uni;
import std.ascii;

class TokenReader {
	string[] tokens;
	int cursor;
	
	this(string[] tokens) {
		this.tokens = tokens;
	}
	
	@property string currentToken() {
		return tokens[cursor];
	}
	
	string getCurrentTokenAndMoveNext() {
		string token = currentToken;
		next();
		return token;
	}
	
	void next() {
		cursor++;
	}
	
	string expect(string value) {
		return expectOne([value]);
	}
	
	string expectOne(string[] values) {
		foreach (value; values) {
			if (currentToken == value) {
				return getCurrentTokenAndMoveNext();
			}
		}
		throw(new Exception(std.string.format("Expecting on token of [%s] but found '%s'", values, currentToken)));
	}
	
	void expectEnd() {
		if (hasMore) throw(new Exception(std.string.format("Expecting end of instruction but found '%s'", currentToken)));
	}
	
	@property bool hasMore() {
		return (cursor < tokens.length);
	}
}

class CpuAssemblerUtils {
	static bool isIdentStart(char c) {
		return isAlphaNum(c) || (c == '%');
	}

	static string[] tokenizeLine(string str) {
		string[] ret;
		
		auto code = { 
			for (int n = 0; n < str.length; n++) {
				char c = str[n];
				switch (c) {
					case ' ': case '\t': break;
					case '\n': case '\r': return;
					case '\'': case '"': {
						char start_c = c;
						int m = n;
						for (n++; n < str.length; n++) {
							if (str[n] == start_c) break;
						}
						ret ~= str[m..n];
						n--;
					} break;
					case ';':
						return;
					break;
					default:
						if (isIdentStart(c)) {
							int m = n;
							for (n++; n < str.length; n++) {
								if (!isAlphaNum(str[n])) break;							
							}
							ret ~= str[m..n];
							n--;
						} else {
							ret ~= [c];
						}
					break;
				}
			}
		};
		code();

		return ret;
	}
}