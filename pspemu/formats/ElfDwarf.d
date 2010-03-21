module pspemu.formats.ElfDwarf;

import pspemu.formats.Elf;

import std.stream, std.string, std.stdio, std.algorithm;

import pspemu.utils.Utils;

//debug = DEBUG_ELF_DWARF_OPCODES;

// Based on: http://www.metastatic.org/source/dwarf2-java.html

class ElfDwarf {
	// 6.2.4 The Statement Program Prologue
	align(1) struct Header {
		uint   total_length;
		ushort _version;
		uint   prologue_length;
		ubyte  minimum_instruction_length;
		ubyte  default_is_stmt;
		byte   line_base;
		ubyte  line_range;
		ubyte  opcode_base;

		uint   total_length_real() { return total_length.sizeof + total_length; }
		
		string toString() {
			return [
				std.string.format("Header {"),
				std.string.format("  total_length    = 0x%X", total_length),
				std.string.format("  version         = %d", _version),
				std.string.format("  prologue_length = 0x%X", prologue_length),
				std.string.format("  minimum_instruction_length = %d", minimum_instruction_length),
				std.string.format("  default_is_stmt = %d", default_is_stmt),
				std.string.format("  line_base       = %d", line_base),
				std.string.format("  line_range      = %d", line_range),
				std.string.format("  opcode_base     = %d", opcode_base),
				std.string.format("}")
			].join("\n");
		}
		
		static assert(this.sizeof == 15);
	}

	// 6.2.5.2 Standard Opcodes
	enum {
		DW_LNS_extended_op      = 0,
		DW_LNS_copy             = 1,
		DW_LNS_advance_pc       = 2,
		DW_LNS_advance_line     = 3,
		DW_LNS_set_file         = 4,
		DW_LNS_set_column       = 5,
		DW_LNS_negate_stmt      = 6,
		DW_LNS_set_basic_block  = 7,
		DW_LNS_const_add_pc     = 8,
		DW_LNS_fixed_advance_pc = 9,
	}

	// 6.2.5.3 Extended Opcodes
	enum {
		DW_LNE_end_sequence = 1,
		DW_LNE_set_address  = 2,
		DW_LNE_define_file  = 3,
	}

	struct FileEntry {
		string name;
		string directory;
		uint   directory_index;
		uint   time_mod;
		uint   size;
		string full_path() {
			if (directory.length) {
				return directory ~ "/" ~ name;
			} else {
				return name;
			}
		}
	}

	// 6.2.2 State Machine Registers
	struct State {
		uint address = 0;
		uint file    = 1;
		uint line    = 1;
		uint column  = 0;
		bool is_stmt = false; // Must be setted by the header.
		bool basic_block = false;
		bool end_sequence = false;
		FileEntry *file_entry;
		
		string file_full_path() { return file_entry.full_path; }
		
		//writefln("DW_LNS_copy: %08X, %s/%s:%d", state.address, directories[files[state.file].directory_index], files[state.file].name, state.line);
		string toString() {
			//return std.string.format("%08X: is_stmt(%d) basic_block(%d) end_sequence(%d) '%s':%d:%d ", address, is_stmt, basic_block, end_sequence, file_entry.full_path, line, column);
			return std.string.format("%08X: '%s':%d:%d ", address, file_entry.full_path, line, column);
		}
	}

	FileEntry[] allFileEntries = [FileEntry()];
	State[uint] pcToState;
	uint[] pcs;
	
	void parseDebugLine(Stream stream) {
		parseDebugLine(cast(ubyte[])stream.readString(cast(uint)stream.size));
	}

	void parseDebugLine(ubyte[] data) {
		ubyte* ptr = data.ptr, end = data.ptr + data.length;
		while (ptr < end) {
			auto header = cast(Header*)ptr;
			parseDebugChunk(header, ptr[0 .. header.total_length_real]);
			ptr += header.total_length_real;
		}
		pcs = pcToState.keys.sort;
		//dump();
		/*
		find(0x08900368);
		find(0x0890036C);
		find(0x08900378);
		find(0x089004C8);
		*/
	}

	State* find(uint PC) {
		/*
		08900368: is_stmt(1) basic_block(0) end_sequence(0) 'test_sprintf.c':15:0 
		08900378: is_stmt(1) basic_block(0) end_sequence(0) 'test_sprintf.c':15:0 
		*/
		auto p = std.algorithm.lowerBound!("a < b")(pcs, PC + 1);
		
		if (!p.length) {
			return null;
		}
		
		State* state = &pcToState[p[$ - 1]];
		
		// Not the address we wanted, and that one was an end_sequence so probably we are out of a function.
		if (state.address != PC && state.end_sequence) {
			return null;
		}

		//writefln("%s", *state);
		return state;
	}

	void dump() {
		foreach (key; pcToState.keys.sort) {
			auto cstate = pcToState[key];
			writefln("%s", cstate);
		}
	}

	string normalizeDirectory(string directory) {
		directory = std.string.replace(directory, "\\", "/");
		
		string[] chunks;
		string[] final_chunks;
		
		int start = 0;
		for (int n = 0; n <= directory.length; n++) {
			if (n == directory.length || directory[n] == '/') {
				chunks ~= directory[start..n];
				start = n + 1;
			}
		}
		
		foreach (k, chunk; chunks) {
			switch (chunk) {
				case "":
					if (k == 0) {
						final_chunks.length = 0;
					}
				break;
				case ".":
				break;
				case "..":
					if (final_chunks.length) final_chunks.length = final_chunks.length - 1;
				break;
				default:
					final_chunks ~= chunk;
				break;
			}
		}
		
		directory = std.string.join(final_chunks, "/");
		/*
		writefln("%s", directory);
		assert(0);
		*/
		
		return directory;
	}
	
	void parseDebugChunk(Header *header, ubyte[] data) {
		//writefln("%s", *header);
		
		string[] directories = [""];
		FileEntry*[] files = [&allFileEntries[0]];
		ulong[] opcode_lengths = [0];
		State state;
		
		state.is_stmt = header.default_is_stmt != 0;

		auto info = new MemoryStream(data[Header.sizeof..header.prologue_length]);
		
		for (int n = 1; n < header.opcode_base; n++) {
			opcode_lengths ~= cast(uint)readUleb128(info);
		}

		// 10. include_directories (sequence of path names)
		while (!info.eof) {
			auto directory = readStringz(info);
			if (!directory.length) break;
			directories ~= normalizeDirectory(directory);
			//writefln("%s", directory);
		}

		// 11. file_names (sequence of file entries)
		while (!info.eof) {
			FileEntry file;
			file.name            = readStringz(info);
			file.directory_index = cast(uint)readUleb128(info);
			file.directory       = directories[file.directory_index];
			file.time_mod        = cast(uint)readUleb128(info);
			file.size            = cast(uint)readUleb128(info);
			allFileEntries ~= file;
			files ~= &allFileEntries[$ - 1];
			if (!file.name.length) break;
		}

		auto program = new MemoryStream(data[header.prologue_length + 9 + 1..$]);
		//writefln("%d", program.size);
		
		//writefln("%s", opcode_lengths);
		
		void copy() {
			debug (DEBUG_ELF_DWARF_OPCODES) writefln("DWARF-2: Copy");
			if (state.address % 4) return; // Invalid address
			state.file_entry = files[state.file];
			pcToState[state.address] = state;
		}
		
		while (!program.eof) {
			auto opcode = read!(ubyte)(program);
			//ulong[] params;
			
			//writefln("Opcode: %d", opcode);

			// Known opcodes.
			if (opcode < header.opcode_base) {
				switch (opcode) {
					case DW_LNS_extended_op: {
						auto ex_len    = readUleb128(program);
						auto ex_opcode = read!(ubyte)(program);
						switch (ex_opcode) {
							case DW_LNE_end_sequence: {
								debug (DEBUG_ELF_DWARF_OPCODES) writefln("DW_LNE_end_sequence");
								state.end_sequence = true;
							} break;
							case DW_LNE_set_address: {
								state.address = read!(uint)(program);
								debug (DEBUG_ELF_DWARF_OPCODES) writefln("DWARF-2: Set address to 0x%08x", state.address);
							} break;
							default:
								throw(new Exception(std.string.format("Unknown extended opcode 0x%02X", ex_opcode)));
							break;
						}
						copy();
					} break;
					case DW_LNS_copy: {
						copy();
					} break;
					case DW_LNS_advance_pc: {
						auto value = readUleb128(program);
						state.address += value * header.minimum_instruction_length;
						debug (DEBUG_ELF_DWARF_OPCODES) writefln("DWARF-2: Advance PC by %d to 0x%08x", value, state.address);
					} break;
					case DW_LNS_advance_line: {
						auto value = readSleb128(program);
						state.line += value;
						debug (DEBUG_ELF_DWARF_OPCODES) writefln("DWARF-2: Advance line by %d to %d", value, state.line);
					} break;
					case DW_LNS_const_add_pc: {
						auto value = (255 - header.opcode_base) / header.line_range;
						state.address += value;
						debug (DEBUG_ELF_DWARF_OPCODES) writefln("DWARF-2: Advance PC by (constant) %d to 0x%08x", value, state.address);
					} break;
					default:
						throw(new Exception(std.string.format("Unknown opcode 0x%02X", opcode)));
					break;
				}
				//copy();
			}
			// Unknown opcodes.
			else {
				int adj = opcode - header.opcode_base;
				int addr_adv = adj / header.line_range;
				int line_adv = header.line_base + (adj % header.line_range);
				state.line    += line_adv;
				state.address += addr_adv;
				//writefln("Special line += %d, address += %d", line_adv, addr_adv);
				debug (DEBUG_ELF_DWARF_OPCODES) writefln("DWARF-2: Special opcode %d advance line by %d to %d and address by %d to 0x%08x", opcode, line_adv, state.line, addr_adv, state.address);
			}
			copy();
		}
		//assert(0);
	}
}

ulong readUleb128(Stream stream) {
	ulong val = 0;
	byte b;
	int shift = 0;

	while (!stream.eof) {
		stream.read(b);
		val |= (b & 0x7F) << shift;
		if ((b & 0x80) == 0) break;
		shift += 7;
	}

	return val;
}

long readSleb128(Stream stream) {
	long val = 0;
	int shift = 0;
	byte b;
	int size = 8 << 3;

	while (!stream.eof) {
		stream.read(b);
		val |= (b & 0x7f) << shift;
		shift += 7;
		if ((b & 0x80) == 0) break;
	}

	if (shift < size && (b & 0x40) != 0)
	val |= -(1 << shift);

	return val;
}

/*
// cls && dmd ..\utils\Utils.d Elf.d -run ElfDwarf.d
void main() {
	auto elf = new Elf(new BufferedFile("../../tests/test_sprintf.elf"));
	auto dwarf = new ElfDwarf;
	dwarf.parseDebugLine(elf.SectionStream(".debug_line"));
	dwarf.dump();
}
*/
