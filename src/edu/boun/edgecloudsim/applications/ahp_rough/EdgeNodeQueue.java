/*
 * One simulated edge node with a single execution slot and a FIFO waiting queue.
 */
package edu.boun.edgecloudsim.applications.ahp_rough;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

class EdgeNodeQueue {
	final int id;
	final double poissonRate;
	private final Queue<TaskVector> waitingTasks = new LinkedList<TaskVector>();
	private TaskVector runningTask;
	private int arrivalsInCurrentWindow;
	private double lastObservedArrivalRate;
	private double smoothedArrivalRate;
	private boolean smoothedArrivalRateInitialized;
	private double lastOffloadTime = -Double.MAX_VALUE;

	EdgeNodeQueue(int id, double poissonRate) {
		this.id = id;
		this.poissonRate = poissonRate;
	}

	void enqueue(TaskVector task) {
		waitingTasks.add(task);
		arrivalsInCurrentWindow++;
	}

	void enqueueOffloaded(TaskVector task) {
		waitingTasks.add(task);
	}

	TaskVector pollNextTask() {
		runningTask = waitingTasks.poll();
		return runningTask;
	}

	void clearRunningTask() {
		runningTask = null;
	}

	boolean isIdle() {
		return runningTask == null;
	}

	int waitingSize() {
		return waitingTasks.size();
	}

	double consumeObservedArrivalRate(double windowSeconds) {
		double rate = arrivalsInCurrentWindow / windowSeconds;
		arrivalsInCurrentWindow = 0;
		lastObservedArrivalRate = rate;
		return rate;
	}

	double getLastObservedArrivalRate() {
		return lastObservedArrivalRate;
	}

	double updateSmoothedArrivalRate(double observedRate, double alpha) {
		if (!smoothedArrivalRateInitialized) {
			smoothedArrivalRate = observedRate;
			smoothedArrivalRateInitialized = true;
		}
		else {
			smoothedArrivalRate = (alpha * observedRate) + ((1.0 - alpha) * smoothedArrivalRate);
		}
		return smoothedArrivalRate;
	}

	double getSmoothedArrivalRate() {
		return smoothedArrivalRate;
	}

	double predictedQueueSize(double predictionHorizon, double serviceRate) {
		double netGrowth = predictionHorizon * (smoothedArrivalRate - serviceRate);
		return Math.max(0.0, waitingTasks.size() + netGrowth);
	}

	boolean hasPredictedDeadlineRisk(double now, double expectedDelayFactor) {
		double predictedBacklog = 0.0;
		if (runningTask != null) {
			predictedBacklog += Math.max(0.0,
					runningTask.actualExecutionTime() - (now - runningTask.startTime));
		}
		for (TaskVector task : waitingTasks) {
			predictedBacklog += task.baseExecutionTime * expectedDelayFactor;
			if (now + predictedBacklog > task.deadline) {
				return true;
			}
		}
		return false;
	}

	boolean canOffload(double now, double cooldownSeconds) {
		return now - lastOffloadTime >= cooldownSeconds;
	}

	void markOffload(double now) {
		lastOffloadTime = now;
	}

	double estimatedBacklogTime(double now) {
		double backlog = 0.0;
		if (runningTask != null) {
			backlog += Math.max(0.0, runningTask.actualExecutionTime() - (now - runningTask.startTime));
		}
		for (TaskVector task : waitingTasks) {
			backlog += task.actualExecutionTime();
		}
		return backlog;
	}

	List<TaskVector> waitingSnapshot() {
		return new ArrayList<TaskVector>(waitingTasks);
	}

	void removeWaitingTasks(List<TaskVector> tasks) {
		waitingTasks.removeAll(tasks);
	}
}
