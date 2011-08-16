module jit.Emmiter;

abstract class Emmiter {
	bool finalized;
	protected ubyte[] buffer;

	static struct Label {
		enum Type { Internal, External }
		
		Type type;
		union {
			void* pointer;
			uint  bufferOffset;
		}
		
		void setInternal(uint bufferOffset) {
			this.type         = Type.Internal;
			this.bufferOffset = bufferOffset;
		}
		
		int getRelativeTo(uint relativeTo) {
			return cast(int)(bufferOffset - relativeTo);
		}
	}
	
	@property uint bufferOffset() {
		return buffer.length;
	}
	
	void setLabelHere(ref Label label) {
		label.setInternal(this.bufferOffset);
	}
	
	struct LabelPlaceHolder {
		Label* label;
		uint relativeStartOffset;
		uint writeOffset;
		
		void setRelative(Label* label, uint relativeStartOffset, uint writeOffset) {
			this.label = label;
			this.relativeStartOffset = relativeStartOffset;
			this.writeOffset = writeOffset;
		}
		
		void writeTo(ubyte[] buffer) {
			void* pointer = cast(void *)&buffer[writeOffset];
			*(cast(int*)pointer) = label.getRelativeTo(relativeStartOffset);
		}
	}
	
	LabelPlaceHolder[] labelPlaceHolders;

	/*	
	interface ILabelPlaceholder {
		void write();
	}
	
	class LabelPlaceholder : ILabelPlaceholder {
		uint bufferOffset;
		ILabel label;
		void write();
	}
	
	ILabel[] labels;
	ILabelPlaceholder[] labelPlaceholders;

	public LabelInternal createLabel() {
		return new LabelInternal();
	}
	
	public LabelInternal createLabelHere() {
		return new LabelInternal().putHere();
	}

	public LabelExternal createLabelToGlobalPointer(void* pointer) {
		return new LabelExternal(pointer);
	}
	*/
	
	void checkNotFinalized() {
		if (finalized) throw(new Exception("Emmiter has been finalized. Can't write on it."));
	}
	
	public void writeLabelBlockRelative4(ref Label label) {
		LabelPlaceHolder labelPlaceHolder;
		labelPlaceHolder.setRelative(&label, 0, this.bufferOffset);
		labelPlaceHolders ~= labelPlaceHolder; 
		write4(0);
	}

	public void writeLabelRelative4(ref Label label, int offset = 0) {
		LabelPlaceHolder labelPlaceHolder;
		labelPlaceHolder.setRelative(&label, this.bufferOffset + offset, this.bufferOffset);
		labelPlaceHolders ~= labelPlaceHolder; 
		write4(0);
	}
	
	//////////////////////
	/// Write Bytes    ///
	//////////////////////
	
	public void write1(ubyte dataToWrite) {
		writeT(dataToWrite);
	}

	public void write2(ushort dataToWrite) {
		writeT(dataToWrite);
	}

	public void write4(uint dataToWrite) {
		writeT(dataToWrite);
	}
	
	public void write8(ulong dataToWrite) {
		writeT(dataToWrite);
	}

	protected void writeT(T)(T dataToWrite) {
		writeE(cast(ubyte[])(&dataToWrite)[0..1]);
	}

	protected void writeE(ubyte[] dataToWrite) {
		checkNotFinalized();
		buffer ~= dataToWrite;
	}
	
	public void write(ubyte[] dataToWrite) {
		checkNotFinalized();
		buffer ~= dataToWrite;
	}
	
	uint execute(Label label) {
		return execute(label.bufferOffset);
	}
	
    uint execute(uint bufferOffset = 0) {
    	if (!finalized) finalize();
        return (cast(uint function())cast(void *)(&buffer[bufferOffset]))();
    }
	
	//////////////////////
	/// Finalize       ///
	//////////////////////

	/**
	 * Update all label references and returns the buffer.
	 */
	public ubyte[] finalize() {
		foreach (ref labelPlaceholder; labelPlaceHolders) {
			labelPlaceholder.writeTo(buffer);
		}
		
		finalized = true;
		
		//labelPlaceHolders.length = 0;
		
		return buffer;
	}
}

class EmmiterLittleEndian : Emmiter {
	protected void writeE(ubyte[] dataToWrite) {
		checkNotFinalized();
		//foreach (b; dataToWrite) buffer ~= b;
		buffer ~= dataToWrite;
	}
}

class EmmiterBigEndian : Emmiter {
	protected void writeE(ubyte[] dataToWrite) {
		checkNotFinalized();
		foreach_reverse (b; dataToWrite) buffer ~= b;
	}
}