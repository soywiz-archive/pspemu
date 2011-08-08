module pspemu.core.cpu.assembler.CpuAssemblerUtils;

import std.uni;
import std.ascii;

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