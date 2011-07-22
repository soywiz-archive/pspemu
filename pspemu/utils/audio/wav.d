module pspemu.utils.audio.wav;

import std.stdio;
import std.stream;
import pspemu.utils.StructUtils;
import pspemu.utils.MathUtils;

class WaveProcessor {
	static struct RiffHeader {
		char[4] riffMagic = "RIFF";
		uint size;
		char[4] waveMagic = "WAVE";
		
		static assert(RiffHeader.sizeof == 12);
	}

	align (2) static struct WaveFormat {
		ushort  compressionCode;    // 01 00       - For Uncompressed PCM (linear quntization)
		ushort  numberOfChannels;   // 02 00       - Stereo
		uint    sampleRate;         // 44 AC 00 00 - 44100
		uint    bytesPerSecond;     // Should be on uncompressed PCM : sampleRate * short.sizeof * numberOfChannels 
		ushort  blockAlignment;     // short.sizeof * numberOfChannels
		ushort  bitsPerSample;      // ???
		ushort  padding;
		
		static WaveFormat getByInfo(ushort numberOfChannels, ushort sampleRate) {
			WaveFormat waveFormat;
			{
				waveFormat.compressionCode  = 1;
				waveFormat.numberOfChannels = numberOfChannels;
				waveFormat.sampleRate       = sampleRate;
				waveFormat.bytesPerSecond   = cast(uint)(short.sizeof * numberOfChannels * sampleRate);
				waveFormat.blockAlignment   = cast(ushort)(short.sizeof * numberOfChannels);
				//waveFormat.bytesPersample   = cast(ushort)(0x8 * numberOfChannels);
				waveFormat.bitsPerSample    = short.sizeof * 8;
			}
			return waveFormat;
		}
	}

	static struct ChunkHeader {
		char[4] type;
		uint    size;
		
		static assert(ChunkHeader.sizeof == 8);
		
		string toString() {
			return std.string.format("ChunkHeader(%s, %d)", type, size);
		}
	}
	
	class Chunk {
		ChunkHeader header;
		Stream      stream;
		long        offset;
		
		public Stream getStream() {
			return new SliceStream(stream, 0, stream.size);
		}
		
		this(ChunkHeader chunkHeader, Stream chunkStream, long chunkOffset) {
			this.header = chunkHeader;
			this.stream = chunkStream;
			this.offset = chunkOffset;
		}
	}
	
	WaveFormat waveFormat;
	Chunk[] chunks;
	Chunk[string] chunksByType;

	this() {
	}
	
	static ubyte[] getBytes(short[] samples, WaveFormat format) {
		auto memoryStream = new MemoryStream();
		write(samples, format, memoryStream);
		return memoryStream.data;
	}
	
	static void write(short[] samples, WaveFormat format, Stream outStream) {
		RiffHeader riffHeader;
		
		riffHeader.size  = 4;
		riffHeader.size += ChunkHeader.sizeof;
		riffHeader.size += format.sizeof;
		riffHeader.size += ChunkHeader.sizeof;
		riffHeader.size += samples.length * samples[0].sizeof;
		
		outStream.write(TA(riffHeader));
		outStream.write(TA(ChunkHeader("fmt ", format.sizeof)));
		outStream.write(TA(format));
		outStream.write(TA(ChunkHeader("data", samples.length * samples[0].sizeof)));
		outStream.write(cast(ubyte[])samples);
	}
	
	public void process(Stream stream) {
		RiffHeader riffHeader;
		stream.read(TA(riffHeader));
		if (riffHeader.riffMagic != RiffHeader.init.riffMagic) throw(new Exception("Not a RIFF file"));
		if (riffHeader.waveMagic != RiffHeader.init.waveMagic) throw(new Exception("Not a RIFF.WAVE file"));
		
		processChunks(new SliceStream(stream, RiffHeader.sizeof, riffHeader.size), RiffHeader.sizeof, 0);
	}

	protected void processChunks(Stream chunksStream, long offset, int level = 0) {
		chunks.length = 0;

		while (!chunksStream.eof) {
			ChunkHeader chunkHeader;
			chunksStream.read(TA(chunkHeader));
			writefln("CHUNK(%d): %s", level, chunkHeader);
			Stream chunkStream = new SliceStream(chunksStream, chunksStream.position, chunksStream.size);
			
			Chunk chunk = new Chunk(chunkHeader, chunkStream, offset + chunksStream.position); 
			chunks ~= chunk;
			chunksByType[cast(string)chunk.header.type] = chunk;
			
			handleChunk(chunk);
			// Level + 1
			//processChunks(chunkStream, offset + stream.position);
			
			chunksStream.seekCur(nextAlignedValue(cast(long)chunkHeader.size, cast(long)2));
		}
	}
	
	protected void handleChunk(Chunk chunk) {
		switch (chunk.header.type) {
			case "fmt ":
				chunk.stream.read(TA(waveFormat));
			break;
			case "data":
			break;
			default:
			break;
		}
	}
}