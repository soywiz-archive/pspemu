module pspemu.utils.Lexer;

import std.utf, std.file, std.stdio, std.string, std.ctype;

class Lexer {
	public struct Token {
		enum Type { INVALID, OPERATOR, ID, INTEGER, FLOAT, STRING, EOF }
		Type  type;
		Lexer lexer;
		wstring value = null;
		uint line = 1, column = 1;

		double fvalue() {
			return std.conv.to!(double)(value);
		}

		long ivalue() {
			return std.conv.to!(long)(value);
		}
		
		bool eof() { return (type == Type.EOF); }

		wstring svalue() {
			wstring r;
			wchar type = value[0];
			assert(type == '\'' || type == '\"');
			assert(value[$ - 1] == type);
			for (int n = 1; n < value.length - 1; n++) {
				wchar c = value[n];
				switch (c) {
					case '\\':
						switch (value[++n]) {
							case 'n': r ~= "\n"; break;
							case 'r': r ~= "\r"; break;
							case 't': r ~= "\t"; break;
							case '\\': r ~= "\\"; break;
							case '\'': r ~= "\'"; break;
							case '\"': r ~= "\""; break;
						}
					break;
					default: r ~= c; break;
				}
			}
			return r;
		}

		string toString() {
			return format("TOKEN at (line: %-3d, column: %-3d) : '%s'", line, column, value);
		}

		bool isOneOf(wstring[] list) {
			if (eof) return false;
			foreach (current; list) if (current == value) return true;
			return false;
		}
		
		bool isNotOneOf(wstring[] list) {
			if (eof) return false;
			return !isOneOf(list);
		}
	
		void printFullContext() {
			writefln("--------------------------------------------");
			writefln("%s:%d:%d", lexer.fileName, line, column);
			writefln("--------------------------------------------");
			printContext();
			writefln("--------------------------------------------");
		}

		void printContext() {
			foreach (c; lexer.fileLines[line - 1]) {
				if (c == '\t') {
					for (int n = 0; n < lexer.tabSize; n++) writef(" ");
				} else {
					writef("%s", c);
				}
			}
			writefln("");
			for (int n = column - 1; n-- > 0; ) writef(" ");
			for (int n = value.length; n-- > 0; ) writef("^");
			writefln("");
			writefln("");
		}
	}

	int tabSize = 4;
	// File Info
	string  fileName;
	wstring fileData;
	uint    fileCursor;
	wstring[] fileLines;

	Token   tokenPrevious, tokenCurrent, tokenNext;
	uint    fileCursorStart, tokenLine, tokenColumn;
	bool    eof;

	void reset() {
		tokenPrevious.lexer = tokenCurrent.lexer = tokenNext.lexer = this;
		eof = false;
		fileCursor = 0;
		fileCursorStart = -1;
		tokenLine = 1;
		tokenColumn = 1;
		next();
	}

	this(string fileName, wstring fileData = null) {
		if (fileData is null) {
			fileData = toUTF16(cast(char[])std.file.read(fileName));
		}
		this.fileName = fileName;
		//this.fileData = fileData ~ " ";
		this.fileData = fileData;
		this.fileLines = split(fileData, "\n"w);
		reset();
	}

	static Lexer fromFile(string fileName) { return new Lexer(fileName); }
	static Lexer fromString(string fileName, wstring contents) { return new Lexer(fileName, contents); }

	// Processes next token.
	protected wchar currentChar;
	private bool next() {
		scope (exit) fileCursor++;

		if (fileCursor < fileData.length) {
			currentChar = fileData[fileCursor];
			if (currentChar == '\n') {
				tokenLine++;
				tokenColumn = 1;
			} else {
				tokenColumn += (currentChar == '\t') ? tabSize : 1;
			}
			return true;
		} else {
			eof = true;
			return false;
		}
	}
	private void updateLineAndColumn() {
		tokenNext.line = tokenLine;
		tokenNext.column = tokenColumn - 1;
		fileCursorStart = fileCursor;
	}
	private void emit(wstring value, Token.Type type = Token.Type.INVALID) {
		tokenNext.value = value;
		tokenNext.type  = type;
		{
			tokenPrevious = tokenCurrent;
			tokenCurrent = tokenNext;
		}
		tokenNext.value = null;
		tokenNext.type = Token.Type.INVALID;
	}
	private wstring captureString(int left = 0, int right = 0) {
		int clamp(int a, int b, int v) { if (v < a) return a; else if (v > b) return b; else return v; }
		int rleft  = fileCursor - left - 1;
		int rright = fileCursor + right - 1;

		if ((clamp(0, fileData.length, rleft) != rleft) || (clamp(0, fileData.length, rright) != rright)) assert(0, format("%d..%d", rleft, rright));

		rleft  = clamp(0, fileData.length, rleft);
		rright = clamp(0, fileData.length, rright);
		assert(rleft < rright);

		//writefln("captureString(%d, %d) : fileData[%d..%d] : '%s'", left, right, rleft, rright, fileData[rleft..rright]);

		return fileData[rleft..rright];
	}

	public bool opCall() {
		static string emitCapture(string s, string type = "Token.Type.OPERATOR") { return "{ emit(captureString(" ~ s ~ "), " ~ type ~ "); return true; }"; }
		int count() { return fileCursor - fileCursorStart; }
		bool contains(wchar v, wchar[] list) { foreach (c; list) if (c == v) return true; return false; }
		static string processDouble(string list) {
			return q{
				next();
				if (contains(currentChar, [} ~ list ~  q{])) {
					next();
					mixin(emitCapture("2"));
				} else {
					mixin(emitCapture("1"));
				}
			};
		}

		while (!eof) {
			updateLineAndColumn();
			switch (currentChar) {
				case '\n':
					//emitCapture("1"); next(); continue;
				case ' ', '\t', '\r': next(); continue;
				case '>': mixin(processDouble("'>', '='"));
				case '<': mixin(processDouble("'<', '='"));
				case '+': mixin(processDouble("'=', '+'"));
				case '-': mixin(processDouble("'=', '-'"));
				case '&', '|', '*', '%', '=', '!': mixin(processDouble("'='"));
				case '/':
				{
					next();
					switch (currentChar) {
						case '*': while (next && (captureString(2) != "*/")) { } continue;
						case '/': while (next && (currentChar != '\n')) { } continue;
						case '=': next(); mixin(emitCapture("2"));
						default: mixin(emitCapture("1"));
					}
				}
				case '"' : do { next(); if (currentChar == '\\') next(); } while (currentChar != '\"'); next(); mixin(emitCapture("count", "Token.Type.STRING"));
				case '\'': do { next(); if (currentChar == '\\') next(); } while (currentChar != '\''); next(); mixin(emitCapture("count", "Token.Type.STRING"));
				default:
				{
					// Number.
					if (isdigit(currentChar)) {
						bool decimal = false;
						do {
							next();
							if (currentChar == '.') {
								if (decimal) {
									break;
								} else {
									decimal = true;
								}
							}
						} while (isdigit(currentChar) || currentChar == '.');
						if (decimal) {
							mixin(emitCapture("count", "Token.Type.FLOAT"));
						} else {
							mixin(emitCapture("count", "Token.Type.INTEGER"));
						}
					}
					// Identifier.
					else if (isalpha(currentChar) || (currentChar == '_') || (currentChar == '$')) {
						do { next(); } while (isalnum(currentChar) || (currentChar == '_') || (currentChar == '$'));
						mixin(emitCapture("count", "Token.Type.ID"));
					}
					// Other single operator.
					else {
						next(); mixin(emitCapture("1"));
					}
				}
				break;
			}
		}
		emit("", Token.Type.EOF);
		return false;
	}

	private Token[] cachedTokens;
	Token[] tokens() {
		if (cachedTokens is null) {
			reset();
			while (opCall()) cachedTokens ~= tokenCurrent;
		}
		return cachedTokens;
	}
	
	wstring[] tokensAsStrings() {
		wstring[] strings;
		foreach (token; tokens) strings ~= token.value;
		return strings;
	}

	void dump() {
		foreach (token; tokens) {
			token.printContext();
		}
	}
}
