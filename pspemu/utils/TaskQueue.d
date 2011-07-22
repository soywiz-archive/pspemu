module pspemu.utils.TaskQueue;

import core.thread;
import pspemu.utils.sync.WaitEvent;

class TaskQueue {
	alias void delegate() Task;
	bool[Task] tasks;
	WaitEvent executedTasksEvent;
	WaitEvent newAvailableTasksEvent;
	
	this() {
		executedTasksEvent = new WaitEvent("TaskQueue.executedTasksEvent");
		newAvailableTasksEvent = new WaitEvent("TaskQueue.newAvailableTasksEvent");
		newAvailableTasksEvent.callback = delegate(Object object) {
			executeAll();
		};
	}
	
	void add(Task task) {
		synchronized (this) {
			tasks[task] = true;
			newAvailableTasksEvent.signal();
		}
	}

	void executeAll() {
		scope Task[] extractedTasks;
		synchronized (this) {
			extractedTasks = tasks.keys.dup;
		}
			
		executedTasksEvent.reset();
		{
			foreach (task; extractedTasks) task();
		}
		newAvailableTasksEvent.reset();
		executedTasksEvent.signal();

		synchronized (this) {
			tasks = null;
		}
	}

	void addAndWait(Task task) {
		add(task);
		waitExecuted(task);
	}

	void waitExecuted(Task task) {
		while (tasks.length) {
			synchronized (this) {
				if ((task in tasks) is null) return;
			}
			executedTasksEvent.wait(1);
		}
	}

	void waitExecutedAll() {
		while (tasks.length) executedTasksEvent.wait(1);
	}

	void opCall() {
		executeAll();
	}
}