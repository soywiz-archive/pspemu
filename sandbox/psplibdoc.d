//#!/dmd -run
import std.stdio, std.xml, std.file;

import pspemu.utils.Expression;

template LazySingleton() {
	static typeof(this) _singleton;
	static typeof(this) singleton() {
		if (_singleton is null) _singleton = new typeof(this);
		return _singleton;
	}
}

class PspLibdoc {
	mixin LazySingleton;

	protected this() {
		this.parse();
	}

	class LibrarySymbol {
		uint nid;
		string name;
		string comment;

		string toString() {
			return std.string.format(typeof(this).stringof ~ "(nid=%s, name='%s' comment='%s')", nid, name, comment);
		}
	}

	class Function : LibrarySymbol { }
	class Variable : LibrarySymbol { }

	class Library {
		string name;
		string flags;
		Function[uint] functions;
		Variable[uint] variables;

		string toString() {
			string s;
			s ~= std.string.format("  <Library name='%s' flags='%s'>\n", name, flags);
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

	void parse() {
		auto xml = new Document(cast(string)std.file.read("../resources/psplibdoc.xml"));
		Function func;
		Variable var;
		Library library;
		Prx prx;

		/*
		void parseSymbol(Type)(Element xml) {
		}
		*/

		void parseFunction(Element xml) {
			func = new Function();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "NID" : func.nid  = cast(uint)parseString(node.text); break;
					case "NAME": func.name = node.text; break;
					case "COMMENT": func.comment = node.text; break;
				}
			}
			library.functions[func.nid] = func;
		}

		void parseVariable(Element xml) {
			var = new Variable();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "NID" : var.nid  = cast(uint)parseString(node.text); break;
					case "NAME": var.name = node.text; break;
					case "COMMENT": var.comment = node.text; break;
				}
			}
			library.variables[var.nid] = var;
		}

		void parseLibrary(Element xml) {
			library = new Library();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "NAME"     : library.name  = node.text; break;
					case "FLAGS"    : library.flags = node.text; break;
					case "FUNCTIONS": foreach (snode; node.elements) if (snode.tag.name == "FUNCTION") parseFunction(snode); break;
					case "VARIABLES": foreach (snode; node.elements) if (snode.tag.name == "VARIABLE") parseVariable(snode); break;
				}
			}
			prx.libraries[library.name] = library;
		}

		void parsePrxFile(Element xml) {
			prx = new Prx();
			foreach (node; xml.elements) {
				switch (node.tag.name) {
					case "PRX"    : prx.fileName   = node.text; break;
					case "PRXNAME": prx.moduleName = node.text; break;
					case "LIBRARIES": foreach (snode; node.elements) if (snode.tag.name == "LIBRARY") parseLibrary(snode); break;
				}
			}
			foreach (library; prx.libraries) libraries[library.name] = library;
			prxs ~= prx;
		}

		foreach (node; xml.elements) if (node.tag.name == "PRXFILES") foreach (snode; node.elements) if (snode.tag.name == "PRXFILE") parsePrxFile(snode);

		foreach (cprx; prxs) {
			writefln("%s", cprx);
		}
	}
}

void main() {
	//testDocumentParser();
	//testDocument();
	writefln("%s", PspLibdoc.singleton.prxs);
}