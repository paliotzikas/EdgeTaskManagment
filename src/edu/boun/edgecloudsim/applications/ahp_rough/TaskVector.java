/*
 * Task vector used by the AHP + rough sets queue scenario.
 */
package edu.boun.edgecloudsim.applications.ahp_rough;

class TaskVector {
	final int id;
	final int sourceNodeId;
	final double arrivalTime;
	final int priority;
	final int steps;
	final double complexity;
	final double deadline;
	final double baseExecutionTime;

	int currentNodeId;
	double startTime = -1;
	double finishTime = -1;
	boolean delayed;
	boolean wasOffloaded;
	int offloadCount;
	double delayMultiplier = 1.0;
	double roughScore;

	TaskVector(int id, int sourceNodeId, double arrivalTime, int priority, int steps,
			double complexity, double deadline, double baseExecutionTime) {
		this.id = id;
		this.sourceNodeId = sourceNodeId;
		this.arrivalTime = arrivalTime;
		this.priority = priority;
		this.steps = steps;
		this.complexity = complexity;
		this.deadline = deadline;
		this.baseExecutionTime = baseExecutionTime;
		this.currentNodeId = sourceNodeId;
	}

	double actualExecutionTime() {
		return baseExecutionTime * delayMultiplier;
	}
}
