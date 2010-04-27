module pspemu.hle.kd.libatrac3plus; // kd/libatrac3plus.prx (sceATRAC3plus_Library)

import pspemu.hle.Module;

class sceAtrac3plus : Module {
	void initNids() {
		mixin(registerd!(0x61EB33F5, sceAtracReleaseAtracID));
		mixin(registerd!(0x7A20E7AF, sceAtracSetDataAndGetID));
		mixin(registerd!(0x6A8C3CD5, sceAtracDecodeData));
		mixin(registerd!(0x9AE849A7, sceAtracGetRemainFrame));
		mixin(registerd!(0x5D268707, sceAtracGetStreamDataInfo));
		mixin(registerd!(0x7DB31251, sceAtracAddStreamData));
		mixin(registerd!(0x83E85EA0, sceAtracGetSecondBufferInfo));
		mixin(registerd!(0x83BF7AFD, sceAtracSetSecondBuffer));
		mixin(registerd!(0xE23E3A35, sceAtracGetNextDecodePosition));
		mixin(registerd!(0xA2BBA8BE, sceAtracGetSoundSample));
		mixin(registerd!(0x868120B5, sceAtracSetLoopNum));
		mixin(registerd!(0xCA3CA3D2, sceAtracGetBufferInfoForReseting));
		mixin(registerd!(0x644E5607, sceAtracResetPlayPosition));
		mixin(registerd!(0xE88F759B, sceAtracGetInternalErrorInfo));
		mixin(registerd!(0xA554A158, sceAtracGetBitrate));
		mixin(registerd!(0x36FAABFB, sceAtracGetNextSample));
		mixin(registerd!(0xB3B5D042, sceAtracGetOutputChannel));
		mixin(registerd!(0xD6A5F2F7, sceAtracGetMaxSample));
	}

	/**
	 * Gets the number of samples of the next frame to be decoded.
	 *
	 * @param atracID - the atrac ID
	 * @param outN - pointer to receives the number of samples of the next frame.
	 *
	 * @return < 0 on error, otherwise 0
	 *
	 */
	int sceAtracGetNextSample(int atracID, int* outN) {
		unimplemented();
		return -1;
	}

	/**
	 * Gets the maximum number of samples of the atrac3 stream.
	 *
	 * @param atracID - the atrac ID
	 * @param outMax  - pointer to a integer that receives the maximum number of samples.
	 *
	 * @return < 0 on error, otherwise 0
	 *
	 */
	int sceAtracGetMaxSample(int atracID, int* outMax) {
		unimplemented();
		return -1;
	}

	void sceAtracGetOutputChannel() {
		unimplemented();
	}

	/**
	 * It releases an atrac ID
	 *
	 * @param atracID - the atrac ID to release
	 *
	 * @return < 0 on error
	 *
	*/
	int sceAtracReleaseAtracID(int atracID) {
		unimplemented();
		return -1;
	}

	/**
	 * Creates a new Atrac ID from the specified data
	 *
	 * @param buf - the buffer holding the atrac3 data, including the RIFF/WAVE header.
	 * @param bufsize - the size of the buffer pointed by buf
	 *
	 * @return the new atrac ID, or < 0 on error 
	*/
	int sceAtracSetDataAndGetID(void *buf, SceSize bufsize) {
		unimplemented();
		return -1;
	}

	/**
	 * Decode a frame of data. 
	 *
	 * @param atracID - the atrac ID
	 * @param outSamples - pointer to a buffer that receives the decoded data of the current frame
	 * @param outN - pointer to a integer that receives the number of audio samples of the decoded frame
	 * @param outEnd - pointer to a integer that receives a boolean value indicating if the decoded frame is the last one
	 * @param outRemainFrame - pointer to a integer that receives either -1 if all at3 data is already on memory, 
	 *  or the remaining (not decoded yet) frames at memory if not all at3 data is on memory
	 *
	 * 
	 * @return < 0 on error, otherwise 0
	 *
	*/
	int sceAtracDecodeData(int atracID, u16 *outSamples, int *outN, int *outEnd, int *outRemainFrame) {
		unimplemented();
		return -1;
	}

	/**
	 * Gets the remaining (not decoded) number of frames
	 * 
	 * @param atracID - the atrac ID
	 * @param outRemainFrame - pointer to a integer that receives either -1 if all at3 data is already on memory, 
	 *  or the remaining (not decoded yet) frames at memory if not all at3 data is on memory 
	 *
	 * @return < 0 on error, otherwise 0
	 *
	*/
	int sceAtracGetRemainFrame(int atracID, int *outRemainFrame) {
		unimplemented();
		return -1;
	}

	/**
	 *
	 * @param atracID - the atrac ID
	 * @param writePointer - Pointer to where to read the atrac data
	 * @param availableBytes - Number of bytes available at the writePointer location
	 * @param readOffset - Offset where to seek into the atrac file before reading
	 *
	 * @return < 0 on error, otherwise 0
	 *
	*/

	int sceAtracGetStreamDataInfo(int atracID, u8** writePointer, u32* availableBytes, u32* readOffset) {
		unimplemented();
		return -1;
	}

	/**
	 *
	 * @param atracID - the atrac ID
	 * @param bytesToAdd - Number of bytes read into location given by sceAtracGetStreamDataInfo().
	 *
	 * @return < 0 on error, otherwise 0
	*/
	int sceAtracAddStreamData(int atracID, uint bytesToAdd) {
		unimplemented();
		return -1;
	}

	// @TODO: UNKNOWN PROTOTYPE.
	void sceAtracGetSecondBufferInfo() {
		unimplemented();
	}

	// @TODO: UNKNOWN PROTOTYPE.
	void sceAtracSetSecondBuffer() {
		unimplemented();
	}

	// @TODO: UNKNOWN PROTOTYPE.
	void sceAtracGetNextDecodePosition() {
		unimplemented();
	}

	// @TODO: UNKNOWN PROTOTYPE.
	void sceAtracGetSoundSample() {
		unimplemented();
	}

	/**
	 * Sets the number of loops for this atrac ID
	 *
	 * @param atracID - the atracID
	 * @param nloops - the number of loops to set
	 *
	 * @return < 0 on error, otherwise 0
	 *
	*/
	int sceAtracSetLoopNum(int atracID, int nloops) {
		unimplemented();
		return -1;
	}

	// @TODO: UNKNOWN PROTOTYPE.
	void sceAtracGetBufferInfoForReseting() {
		unimplemented();
	}

	// @TODO: UNKNOWN PROTOTYPE.
	void sceAtracResetPlayPosition() {
		unimplemented();
	}

	// @TODO: UNKNOWN PROTOTYPE.
	void sceAtracGetInternalErrorInfo() {
		unimplemented();
	}
	
	/**
	 * Gets the bitrate.
	 *
	 * @param atracID - the atracID
	 * @param outBitrate - pointer to a integer that receives the bitrate in kbps
	 *
	 * @return < 0 on error, otherwise 0
	 *
	 */
	int sceAtracGetBitrate(int atracID, int* outBitrate) {
		unimplemented();
		return -1;
	}
}

static this() {
	mixin(Module.registerModule("sceAtrac3plus"));
}
