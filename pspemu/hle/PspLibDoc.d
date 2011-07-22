module pspemu.hle.PspLibDoc;

import std.stdio;
import std.xml;

import pspemu.utils.ExceptionUtils;
import pspemu.utils.Expression;

__gshared const string psplibdoc_xml = import("psplibdoc.xml");

/**
 * One singleton per all threads.
 */
template LazySingleton() {
	//static typeof(this) _singleton;
	__gshared typeof(this) _singleton;
	static typeof(this) singleton() {
		if (_singleton is null) {
			//writefln("Building...");
			_singleton = new typeof(this);
			//writefln("Building...OK");
		}
		return _singleton;
	}
}

class DPspLibdoc {
	mixin LazySingleton;

	protected this() {
		this.parse();
	}

	class LibrarySymbol {
		uint nid;
		string name;
		string comment;
		Library library;

		string toString() {
			return std.string.format(typeof(this).stringof ~ "(nid=0x%08X, name='%s' comment='%s')", nid, name, comment);
		}
	}

	class Function : LibrarySymbol { }
	class Variable : LibrarySymbol { }

	class Library {
		string name;
		uint flags;
		Function[uint] functions;
		Variable[uint] variables;
		LibrarySymbol[uint] symbols;
		Prx prx;

		string toString() {
			string s;
			s ~= std.string.format("  <Library name='%s' flags='0x%08x'>\n", name, flags);
			foreach (func; functions) s ~= std.string.format("    %s\n", func.toString);
			foreach (var ; variables) s ~= std.string.format("    %s\n", var .toString);
			s ~= std.string.format("  </Library>");
			return s;
		}
	}

	class Prx {
		string moduleName, fileName;
		Library[string] libraries;
		
		string toString() {
			string s;
			s ~= std.string.format("<Prx moduleName='%s' fileName='%s'>\n", moduleName, fileName);
			foreach (library; libraries) s ~= std.string.format("%s\n", library.toString);
			s ~= std.string.format("</Prx>");
			return s;
		}
	}

	Library[string] libraries;
	Prx[] prxs;

	LibrarySymbol locate(uint nid, string libraryName) {
		if (libraryName is null) {
			foreach (clibraryName; libraries.keys) if (auto symbol = locate(nid, clibraryName)) return symbol;
			return null;
		}
		if (libraryName !in libraries) return null;
		if (nid !in libraries[libraryName].symbols) return null;
		return libraries[libraryName].symbols[nid];
	}

	string getPrxPath(string libraryName) {
		return onException(libraries[libraryName].prx.fileName, "<unknown path>");
	}
	
	string getPrxName(string libraryName) {
		return onException(libraries[libraryName].prx.moduleName, "<unknown name>");
	}
	
	string getPrxInfo(string libraryName) {
		return std.string.format("%s (%s)", getPrxPath(libraryName), getPrxName(libraryName));
	}

	void parse() {
		auto xml = new Document(psplibdoc_xml);
		Function func;
		Variable var;
		Library library;
		Prx prx;

		void parseFunction(Element xml) {
			func = new Function();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "NID" : func.nid  = cast(uint)parseString(node.text); break;
					case "NAME": func.name = node.text; break;
					case "COMMENT": func.comment = node.text; break;
					default: throw(new Exception("Unknown tag name"));
				}
			}
			func.library = library;
			library.functions[func.nid] = func;
			library.symbols[func.nid] = func;
		}

		void parseVariable(Element xml) {
			var = new Variable();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "NID" : var.nid  = cast(uint)parseString(node.text); break;
					case "NAME": var.name = node.text; break;
					case "COMMENT": var.comment = node.text; break;
					default: throw(new Exception("Unknown tag name"));
				}
			}
			var.library = library;
			library.variables[var.nid] = var;
			library.symbols[var.nid] = var;
		}

		void parseLibrary(Element xml) {
			library = new Library();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "NAME"     : library.name  = node.text; break;
					case "FLAGS"    : library.flags = cast(uint)parseString(node.text); break;
					case "FUNCTIONS": foreach (snode; node.elements) if (snode.tag.name == "FUNCTION") parseFunction(snode); break;
					case "VARIABLES": foreach (snode; node.elements) if (snode.tag.name == "VARIABLE") parseVariable(snode); break;
					default: throw(new Exception("Unknown tag name"));
				}
			}
			library.prx = prx;
			prx.libraries[library.name] = library;
		}

		void parsePrxFile(Element xml) {
			prx = new Prx();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "PRX"    : prx.fileName   = node.text; break;
					case "PRXNAME": prx.moduleName = node.text; break;
					case "LIBRARIES": foreach (snode; node.elements) if (snode.tag.name == "LIBRARY") parseLibrary(snode); break;
					default: throw(new Exception("Unknown tag name"));
				}
			}
			foreach (library; prx.libraries) libraries[library.name] = library;
			prxs ~= prx;
		}

		foreach (node; xml.elements) if (node.tag.name == "PRXFILES") foreach (snode; node.elements) if (snode.tag.name == "PRXFILE") parsePrxFile(snode);

		//foreach (cprx; prxs) writefln("%s", cprx);
	}
}