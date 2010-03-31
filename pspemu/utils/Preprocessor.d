module pspemu.utils.Preprocessor;

// WIP

import std.string, std.stdio, std.regex;

/*
#define DEMO
#ifdef DEMO
	#define TEST 1
#else
	#ifdef DEMO
		#define TEST 2
	#else
		#define TEST 3
	#endif
#endif
*/

class Preprocessor {
	static struct IfState {
		bool ifPass;
	}

	class State {
		string[] includePaths;
		string[string] symbols;
		IfState[] ifStack;
		bool parentIfPass() { return ifStack.length ? ifStack[$ - 1].ifPass : true; }
		bool ifPass = true;
		void pushIfState() { ifStack ~= IfState(ifPass); }
		void popIfState() { ifPass = ifStack[$ - 1].ifPass; ifStack.length = ifStack.length - 1; }
	}

	string file;
	string originalCode, processedCode;
	string[] originalLines, processedLines;
	State state;

	this(State state = null) {
		if (state is null) state = new State;
		this.state = state;
	}

	void load(string code, string[] includePaths = null) {
		this.originalLines = std.string.split(code, "\n");
		//this.processedCode = this.originalCode = code;
		this.state.includePaths = includePaths;
	}

	void process() {
		auto regexPreprocessorLine = regex(r"^\s*#(\w+)(\s+.*)?$");
		//auto regexPreprocessorDefine = regex(r"^(\w+)(\(\))?\s+(.+)$");
		auto regexPreprocessorDefine = regex(r"^(\w+)\s*([^\s]*)\s*$");

		processedLines = [];
		foreach (line; originalLines) {
			auto matches = match(line, regexPreprocessorLine);

			if (!matches.empty) {
				foreach (m; matches) {
					auto captures = m.captures;
					auto type = std.string.tolower(captures[1]);
					string params;
					if (captures.length > 2) params = std.string.strip(captures[2]);

					switch (type) {
						case "define":
							if (state.ifPass) {
								foreach (m2; match(params, regexPreprocessorDefine)) {
									state.symbols[m2.captures[1]] = (m2.captures.length > 2) ? m2.captures[2] : "";
								}
								//writefln("%s: %s", type, params);
							}
						break;
						case "ifdef":
							state.pushIfState();
							state.ifPass = state.parentIfPass && (params in state.symbols);
						break;
						case "else":
							state.ifPass = state.parentIfPass && (!state.ifPass);
						break;
						case "endif":
							state.popIfState();
						break;
					}
					//writefln("%s: %s", type, params);
				}
			} else if (state.ifPass) {
				writefln("%s", line);
				processedLines ~= line;
			}
		}
	}
}
/*
void main() {
	auto p = new Preprocessor;
	p.load(cast(string)std.file.read("Preprocessor.d"));
	p.process();
}
*/