module pspemu.utils.Reference;

class ReferenceObject {
	public int __referenceCount;
}

class Reference {
	static ref T capture(T : ReferenceObject)(ref T object) {
		object.__referenceCount++;
		return object;
	}

	static void release(T : ReferenceObject)(ref T object) {
		object.__referenceCount--;
		if (object.__referenceCount <= 0) {
			delete object;
			object = null;
		}
	}
}