module pspemu.hle.elf.HleElfLoader;

import pspemu.hle.elf.Elf;
import pspemu.hle.elf.ElfReloc;
import pspemu.hle.HleMemoryManager;
import pspemu.utils.StreamUtils;
import pspemu.utils.MathUtils;
import pspemu.core.cpu.Instruction;

import std.stdio;

import pspemu.utils.Logger;

class HleElfLoader {
	protected Elf elf;
	protected HleMemoryManager hleMemoryManager;
	public uint relocationAddress;
	
	this(Elf elf, HleMemoryManager hleMemoryManager) {
		this.elf = elf;
		this.hleMemoryManager = hleMemoryManager;
	}
	
	public void writeToMemory(Stream memoryStream) {
		foreach (k, sectionHeader; elf.sectionHeaders) {			
			uint sectionHeaderOffset = cast(uint)(relocationAddress + sectionHeader.address);
			
			string typeString = "None";
			
			// Section to allocate
			if (sectionHeader.flags & ElfSectionHeader.Flags.Allocate) {
				//Logger.log(Logger.Level.DEBUG, "Loader", "Starting to write to: %08X. ElfSectionHeader: %s", sectionHeaderOffset, sectionHeader);

				bool reserved = true;
				
				memoryStream.position = sectionHeaderOffset;
				switch (sectionHeader.type) {
					default: reserved = false; typeString = "UNKNOWN"; break;
					case ElfSectionHeader.Type.PROGBITS: typeString = "PROGBITS"; memoryStream.copyFrom(elf.SectionStream(sectionHeader)); break;
					case ElfSectionHeader.Type.NOBITS  : typeString = "NOBITS"  ; writeZero(memoryStream, sectionHeader.size); break;
				}
				
				debug (MODULE_LOADER) writefln("%-16s: %08X[%08X] (%s)", typeString, sectionHeaderOffset, sectionHeader.size, sectionHeaderNames[k]);
			}
			// Section not to allocate
			else {
				debug (MODULE_LOADER) writefln("%-16s: %08X[%08X] (%s)", typeString, sectionHeaderOffset, sectionHeader.size, sectionHeaderNames[k]);
			}
		}
		if (elf.needsRelocation) {
			//throw(new Exception("Relocation not implemented yet!"));
			try {
				relocateFromHeaders(memoryStream);
			} catch (Throwable o) {
				writefln("Error relocating: %s", o.toString);
				throw(o);
			}
		}
	}
	
	protected void relocateFromHeaders(Stream memoryStream) {
		if ((relocationAddress & 0xFFFF) != 0) {
			//throw(new Exception("Relocation base address not aligned to 64K"));
			logWarning("Relocation base address not aligned to 64K");
		}
		
        foreach (programHeader; elf.programHeaders) {
        	// @TODO
        	// ProgramStream();
        	//ProgramStream
        	/*
            if (phdr.getP_type() == 0x700000A0L) {
                int RelCount = (int)phdr.getP_filesz() / Elf32Relocate.sizeof();
                Memory.log.debug("PH#" + i + ": relocating " + RelCount + " entries");

                f.position((int)(elfOffset + phdr.getP_offset()));
                relocateFromBuffer(f, module, baseAddress, elf, RelCount);
                return;
            } else if (phdr.getP_type() == 0x700000A1L) {
                Memory.log.warn("Unimplemented:PH#" + i + ": relocate type 0x700000A1");
            }
            i++;
            */
        }

		foreach (sectionHeader; elf.sectionHeaders) {
			switch (sectionHeader.type) {
				case ElfSectionHeader.Type.PRXRELOC:
					relocateFromStream(elf.SectionStream(sectionHeader), memoryStream);
				break;
				case ElfSectionHeader.Type.REL:
					logWarning("Not relocating ElfSectionHeader.Type.REL");
				break;
				case ElfSectionHeader.Type.PRXRELOC_FW5:
					// http://forums.ps2dev.org/viewtopic.php?p=80416#80416
					throw(new Exception("Not implemented ElfSectionHeader.Type.PRXRELOC2"));
				break;
				default:
				break;
			}
		}	
	}

	protected void relocateFromStream(Stream stream, Stream memoryStream) {
		uint memory_read32(uint position) {
			try {
				memoryStream.position = position;
				return read!(uint)(memoryStream);
			} catch (Throwable o) {
				logError("memory_read32: %s", o);
				throw(new Exception(std.string.format("Error on memory_read32 %08X", position)));
				return -1;
			}
		}

		uint memory_write32(uint position, uint data) {
			try {
				memoryStream.position = position;
				memoryStream.write(data);
				return data;
			} catch (Throwable o) {
				logError("memory_write32: %s", o);
				throw(new Exception(std.string.format("memory_write32: %08X", position)));
				return data;
			}
		}

		uint[][32] regs;
		uint RelocCount = cast(uint)stream.size / ElfReloc.sizeof;
		uint AHL = 0; // (AHI << 16) | (ALO & 0xFFFF)
		scope uint[] deferredHi16;

		for (int n = 0; n < RelocCount; n++) {
			auto elfReloc = read!(ElfReloc)(stream);
			// Filtra las relocalizaciones nulas
			if (elfReloc.type == ElfReloc.Type.None) continue;
			
			// Program header offset of the reference we want to relocate. 
			int phOffset     = elf.programHeaders[elfReloc.offsetBase].virtualAddress;
			
			// Program header offset of the program header referenced by this relocation.
        	int phBaseOffset = elf.programHeaders[elfReloc.addressBase].virtualAddress;

			// Obtiene el offset real a relocalizar 
			uint data_addr = relocationAddress + elfReloc.offset + phOffset;
			
			int A = 0; // addend
			int S = relocationAddress + phBaseOffset;
			int GP_ADDR = relocationAddress + elfReloc.offset;
			int GP_OFFSET = GP_ADDR - (relocationAddress & 0xFFFF0000);
			
			long result = 0; // Used to hold the result of relocation, OR this back into data
			
			// Lee la palabra original
			Instruction instruction = Instruction(memory_read32(data_addr));
			
			//writefln("Patching offset: %08X, type:%d", offset, elfReloc.type);

			uint prev_data = instruction.v;
			
			void logAsJpcsp(T...)(T args) {
				//writefln("TRACE   memory - GUI - %s", std.string.format(args));
				elf.logTrace(args);
			}

			logAsJpcsp("Relocation #%d type=%d,base=%08X,addr=%08X", n, elfReloc.type, elfReloc.offsetBase, elfReloc.addressBase);

			// Modifica la palabra según el tipo de relocalización
			switch (elfReloc.type) {
				default: throw(new Exception(std.string.format("RELOC: unknown elfReloc type '%02X'", elfReloc.type)));
				//case ElfReloc.Type.MipsNone:
				// LUI
				case ElfReloc.Type.MipsHi16: { 
					//regs[instruction.RT] ~= offset;
					//instruction.IMMU = instruction.IMMU + (baseAddress >> 16);

					A = instruction.IMMU;
					AHL = A << 16;
					deferredHi16 ~= data_addr;

                    logAsJpcsp(std.string.format("R_MIPS_HI16 addr=%08X", data_addr));
				} break;
				
				// ADDI, ORI ...
				case ElfReloc.Type.MipsLo16: {
					A = instruction.IMMU;
					AHL &= ~0x0000FFFF; // delete lower bits, since many R_MIPS_LO16 can follow one R_MIPS_HI16
					AHL |= A & 0x0000FFFF;
					result = AHL + S;
					instruction.v &= ~0x0000FFFF;
					instruction.v |= result & 0x0000FFFF; // truncate
					// Process deferred R_MIPS_HI16
					foreach (data_addr2; deferredHi16) {
						int data2 = memory_read32(data_addr2);
						result = ((data2 & 0x0000FFFF) << 16) + A + S;
						// The low order 16 bits are always treated as a signed
						// value. Therefore, a negative value in the low order bits
						// requires an adjustment in the high order bits. We need
						// to make this adjustment in two ways: once for the bits we
						// took from the data, and once for the bits we are putting
						// back in to the data.
						if ((A & 0x8000) != 0) {
						    result -= 0x10000;
						}
						if ((result & 0x8000) != 0) {
						     result += 0x10000;
						}
						data2 &= ~0x0000FFFF;
						data2 |= (result >> 16) & 0x0000FFFF; // truncate
						logAsJpcsp(std.string.format("R_MIPS_HILO16 addr=%08X before=%08X after=%08X", data_addr2, memory_read32(data_addr2), data2));
					    memory_write32(data_addr2, data2);
					}
				    deferredHi16.length = 0;

					logAsJpcsp(std.string.format("R_MIPS_LO16 addr=%08X before=%08X after=%08X", data_addr, prev_data, instruction.v));
				} break;
				
				// J, JAL
				case ElfReloc.Type.Mips26:
					instruction.JUMP2 = instruction.JUMP2 + S;
					
					logAsJpcsp(std.string.format("R_MIPS_26 addr=%08X before=%08X after=%08X", data_addr, prev_data, instruction.v));
				break;
	
				// *POINTER*
				case ElfReloc.Type.Mips32:
					//instruction.v = instruction.v + baseAddress;
					instruction.v += S;
					logAsJpcsp(std.string.format("R_MIPS_32 addr=%08X before=%08X after=%08X", data_addr, prev_data, instruction.v));
				break;
				
				case ElfReloc.Type.MipsGpRel16: {
					/*
					A = instruction.IMMU;
                    if (A == 0) {
                        result = S - GP_ADDR;
                    } else {
                        result = S + GP_OFFSET + (((A & 0x00008000) != 0) ? (((A & 0x00003FFF) + 0x4000) | 0xFFFF0000) : A) - GP_ADDR;
                    }
                    if ((result > 32768) || (result < -32768)) {
						logError("GP_ADDR:%08X, GP_OFFSET:%08X", GP_ADDR, GP_OFFSET);
                        logError("Relocation overflow (R_MIPS_GPREL16) %d", result);
                    }
                    instruction.IMMU = cast(uint)result;
                    */
                    
                   	logWarningOnce("elfgp16", "ElfReloc.Type.MipsGpRel16");
					
					logAsJpcsp(std.string.format("R_MIPS_GPREL16 addr=%08X before=%08X after=%08X", data_addr, prev_data, instruction.v));
				} break;
			} // switch

			//logTrace("%s addr=%08X before=%08X after=%08X", to!string(elfReloc.type), offset, prev_data, instruction.v);
			//writefln("TRACE   memory - GUI - %s addr=%08X before=%08X after=%08X", to!string(cast(ElfReloc.Type2)elfReloc.type), offset, prev_data, instruction.v);
			
			// Escribe la palabra modificada
			memory_write32(data_addr, instruction.v);
			
		} // while
	}

	uint requiredBlockSize() {
		uint low, high;
		allocateBlockBound(low, high);
		return high - low;
	}

	uint suggestedBlockAddress() {
		uint low, high;
		allocateBlockBound(low, high);
		return high;
	}

	void allocateBlockBound(ref uint low, ref uint high) {
		low  = 0xFFFFFFFF;
		high = 0x00000000;
		foreach (sectionHeader; elf.sectionHeaders) {
			if (sectionHeader.flags & ElfSectionHeader.Flags.Allocate) {
				switch (sectionHeader.type) {
					case ElfSectionHeader.Type.PROGBITS, ElfSectionHeader.Type.NOBITS:
						low  = min(low , sectionHeader.address);
						high = max(high, sectionHeader.address + sectionHeader.size);
					break;
					default: break;
				}
			}
		}
	}

	protected void allocateMemory() {
		if (elf.needsRelocation) {
			relocationAddress = hleMemoryManager.allocHeap(PspPartition.User, "ModuleMemory", elf.sectionHeaderTotalSize).block.low;
		} else {
			relocationAddress = 0;
			foreach (k, sectionHeader; elf.sectionHeaders) {
				uint sectionHeaderOffset = cast(uint)(relocationAddress + sectionHeader.address);

				// Section to allocate
				if (sectionHeader.flags & ElfSectionHeader.Flags.Allocate) {
					hleMemoryManager.allocAt(PspPartition.User, "ModuleMemory", sectionHeader.size, sectionHeaderOffset);
				}
			}
		}
	}

	mixin Logger.DebugLogPerComponent!("HleElfLoader");
}