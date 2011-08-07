module pspemu.formats.audio.Vag;

import std.string;
import std.stdio;
import std.file;
import std.conv;
import pspemu.utils.StructUtils;
import pspemu.utils.BitUtils;
import pspemu.utils.MathUtils;

import pspemu.utils.audio.wav;

/**
 * Based on jpcsp. gid15 work.
 * http://code.google.com/p/jpcsp/source/browse/trunk/src/jpcsp/sound/SampleSourceVAG.java?r=1995
 */
class VAG {
	ubyte[] data;
	Header* header;
	Block[] blocks;
	short[] decodedSamples;
	
	const float[][] VAG_f = [
        [   0.0 / 64.0,   0.0 / 64.0 ],
        [  60.0 / 64.0,   0.0 / 64.0 ],
        [ 115.0 / 64.0, -52.0 / 64.0 ],
        [  98.0 / 64.0, -55.0 / 64.0 ],
        [ 122.0 / 64.0, -60.0 / 64.0 ],
    ];
	
	static struct Header {
		char[3]  magic = "VAG";
		char     magic2;
		be!uint  vagVersion;
		be!uint  dataSize;
		be!uint  sampleRate;
		char[16] name;
		
		string toString() {
			string s;
			s ~= "VAG(";
			s ~= std.string.format("magic=%s,", magic);
			s ~= std.string.format("vagVersion=%d,", vagVersion);
			s ~= std.string.format("dataSize=%d,", dataSize);
			s ~= std.string.format("sampleRate=%d,", sampleRate);
			s ~= std.string.format("name='%s',", to!string(name.ptr));
			s ~= ")";
			return s;
		}
		
		static assert (Header.sizeof == 0x20);
	}
	
	static struct Block {
		enum Type : ubyte {
			None      = 0,
			LoopEnd   = 3,
			LoopStart = 6,
			End       = 7,
		}
		
		ubyte     mod;
		Type      type;
		ubyte[14] data;
		
		static assert (Block.sizeof == 0x10);
	}
	
	short[] decodeBlocks(Block[] blocks) {
		short[] samples = new short[blocks.length * 28];
		int sampleOffset = 0;
		
		short hist1 = 0, hist2 = 0;
		
		foreach (ref block; blocks) {
			int predict_nr   = BitUtils.extract!(int, 4, 4)(block.mod) % VAG_f.length;
			int shift_factor = BitUtils.extract!(int, 0, 4)(block.mod);
			//if (predict_nr > VAG_f.length) predict_nr = 0; 
			
			if (block.type == Block.Type.End) break;
			
			// @TODO: maybe we can change << 12 >> shift_factor for "<< (12 - shift_factor)"
			// and move the substract outside the for. 
			
			float predict1 = VAG_f[predict_nr][0];
			float predict2 = VAG_f[predict_nr][1];
			
			//writefln("Predict: %f, %f", predict1, predict2);
			
			short handleSample(int unpackedSample) {
				int sample = 0;
				sample += unpackedSample * 1;
				sample += hist1 * predict1;
				sample += hist2 * predict2;
				return cast(short)clamp(sample, -32768, +32767); 
			}
			
			void putSample(int unpackedSample) {
				short sample = handleSample(unpackedSample);
				hist2 = hist1;
				hist1 = sample;
				samples[sampleOffset++] = sample;
			}
			
			// Mono 4-bit/28 Samples per block.
			foreach (dataByte; block.data) {
				putSample((cast(short)(BitUtils.extract!(int, 0, 4)(dataByte) << 12)) >> shift_factor);
				putSample((cast(short)(BitUtils.extract!(int, 4, 4)(dataByte) << 12)) >> shift_factor);
			}
		}
		
		samples.length = sampleOffset;
		
		return samples;
	}
	
	public void load(ubyte[] data) {
		//std.file.write("TEMP_AUDIO_DAT.BIN", data);

		this.data = data;
		header = cast(Header*)data.ptr;
		switch (header.magic) {
			case "VAG":
				blocks = cast(Block[])data[0x30..$];
			break;
			case "\0\0\0":
				blocks = cast(Block[])data[0x10..$];
			break;
			default: throw(new Exception("Not a valid VAG File."));
		}
		
		//writefln("%s", this.header.toString);
		
		decodedSamples = decodeBlocks(blocks);
	}
}
