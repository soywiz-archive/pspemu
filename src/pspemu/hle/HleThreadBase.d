module pspemu.hle.HleThreadBase;

abstract class HleThreadBase {
	public int waitCount;
	abstract public void threadResume();
	abstract public @property int currentPriority();
	abstract public @property bool threadFinished();
}