module pspemu.utils.BindLibrary;

import std.string;
import std.c.windows.windows;
import std.stdio;

import pspemu.utils.String;

void BindLibraryFunctions(string base, string member, string dll, alias bindTemplate, string prefixTo = "", string prefixFrom = "", bool check = true)() {
	string ProcessMember(string name) {
		string[string] map;
		map["dname"     ] = prefixTo ~ name;
		map["importName"] = prefixFrom ~ name;
		map["dll"       ] = dll;
		return stringInterpolate(member, map);
	}

	mixin(base);
	foreach (member; __traits(derivedMembers, bindTemplate)) {
		mixin(ProcessMember(member));
	}
}

void BindLibrary(string dll, alias bindTemplate, string prefixTo = "", string prefixFrom = "", bool check = true)() {
	BindLibraryFunctions!(q{
		HANDLE lib = LoadLibraryA(dll);
		if (lib is null) throw(new Exception(std.string.format("Can't load library '%s'", dll)));
	}, q{
		{ static if (__traits(compiles, &{$dname})) {
			void* addr = cast(void*)GetProcAddress(lib, "{$importName}");
			if (check) if (addr is null) throw(new Exception(std.string.format("Can't load '%s' from '%s'", "{$importName}", "{$dll}")));
			*cast(void**)&{$dname} = addr;
		} }
	}, dll, bindTemplate, prefixTo, prefixFrom, check);
}
