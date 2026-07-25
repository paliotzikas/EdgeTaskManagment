/*
 * CloudSim entity implementing the requested N-node queue scenario.
 */
package edu.boun.edgecloudsim.applications.ahp_rough;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Random;

import org.cloudbus.cloudsim.core.CloudSim;
import org.cloudbus.cloudsim.core.SimEntity;
import org.cloudbus.cloudsim.core.SimEvent;

class AhpRoughSimulation extends SimEntity {
	private static final int ARRIVAL_TICK = 1;
	private static final int FINISH_TASK = 2;
	private static final int STOP_SIMULATION = 3;

	private final ScenarioConfig config;
	private final String outputFolder;
	private final EdgeNodeQueue[] nodes;
	private final double[] poissonMeans;
	private final AhpRoughSetSelector selector;
	private final Random workloadRandom;
	private final Random policyRandom;
	private final String offloadingPolicy;
	private final String offloadDestinationPolicy;
	private final String thresholdMode;
	private final String decisionMode;
	private final long effectiveSeed;
	private final double simulationTime;
	private final double arrivalTickSeconds;
	private final double highArrivalRateThreshold;
	private final double thresholdMultiplier;
	private final double delayProbability;
	private final double minDelayMultiplier;
	private final double maxDelayMultiplier;
	private final double offloadFraction;
	private final int maxOffloadsPerEvent;
	private final int maxTaskOffloads;
	private final double minExecutionTime;
	private final double maxExecutionTime;
	private final int minPriority;
	private final int maxPriority;
	private final int minSteps;
	private final int maxSteps;
	private final double minComplexity;
	private final double maxComplexity;
	private final double minDeadlineSlack;
	private final double maxDeadlineSlack;
	private final double arrivalEwmaAlpha;
	private final double predictionHorizon;
	private final double proactiveQueueMultiplier;
	private final double proactiveMinQueueThreshold;
	private final double offloadCooldown;
	private final boolean reactiveFallbackEnabled;
	private final double expectedDelayFactor;
	private final double estimatedServiceRate;

	private PrintWriter taskLog;
	private PrintWriter nodeLog;
	private int nextTaskId = 1;
	private int completedTasks;
	private int offloadedTasks;
	private int receivedOffloadedTasks;
	private int completedOffloadedTasks;
	private int delayedTasks;
	private int proactiveTriggerEvents;
	private int reactiveTriggerEvents;
	private int completedDeadlineMisses;

	AhpRoughSimulation(ScenarioConfig config, String outputFolder, int iterationNumber) {
		super("AhpRoughSimulation");
		this.config = config;
		this.outputFolder = outputFolder;
		this.offloadingPolicy = config.getString("offloading_policy", "AHP_ROUGH").toUpperCase(Locale.US);
		this.offloadDestinationPolicy = config.getString("offload_destination_policy", "DROP").toUpperCase(Locale.US);
		this.thresholdMode = config.getString("threshold_mode", "FIXED").toUpperCase(Locale.US);
		this.decisionMode = config.getString("decision_mode", "REACTIVE").toUpperCase(Locale.US);
		this.simulationTime = config.getDouble("simulation_time", 600.0);
		this.arrivalTickSeconds = config.getDouble("arrival_tick_seconds", 1.0);
		this.highArrivalRateThreshold = config.getDouble("high_arrival_rate_threshold", 3.0);
		this.thresholdMultiplier = config.getDouble("threshold_multiplier", 1.0);
		this.delayProbability = config.getDouble("delay_probability", 0.25);
		this.minDelayMultiplier = config.getDouble("min_delay_multiplier", 1.5);
		this.maxDelayMultiplier = config.getDouble("max_delay_multiplier", 3.0);
		this.offloadFraction = config.getDouble("offload_fraction", 0.40);
		this.maxOffloadsPerEvent = config.getInt("max_offloads_per_event", 5);
		this.maxTaskOffloads = config.getInt("max_task_offloads", 1);
		this.minExecutionTime = config.getDouble("min_execution_time", 2.0);
		this.maxExecutionTime = config.getDouble("max_execution_time", 8.0);
		this.minPriority = config.getInt("min_priority", 1);
		this.maxPriority = config.getInt("max_priority", 10);
		this.minSteps = config.getInt("min_steps", 1);
		this.maxSteps = config.getInt("max_steps", 20);
		this.minComplexity = config.getDouble("min_complexity", 1.0);
		this.maxComplexity = config.getDouble("max_complexity", 10.0);
		this.minDeadlineSlack = config.getDouble("min_deadline_slack", 20.0);
		this.maxDeadlineSlack = config.getDouble("max_deadline_slack", 120.0);
		this.arrivalEwmaAlpha = config.getDouble("arrival_ewma_alpha", 0.30);
		this.predictionHorizon = config.getDouble("prediction_horizon_seconds", 10.0);
		this.proactiveQueueMultiplier = config.getDouble("proactive_queue_multiplier", 1.20);
		this.proactiveMinQueueThreshold = config.getDouble("proactive_min_queue_threshold", 5.0);
		this.offloadCooldown = config.getDouble("offload_cooldown_seconds", 5.0);
		this.reactiveFallbackEnabled = config.getInt("reactive_fallback_enabled", 1) == 1;
		this.expectedDelayFactor = 1.0 + delayProbability *
				(((minDelayMultiplier + maxDelayMultiplier) / 2.0) - 1.0);
		double expectedExecutionTime = ((minExecutionTime + maxExecutionTime) / 2.0) * expectedDelayFactor;
		this.estimatedServiceRate = 1.0 / expectedExecutionTime;
		validateDecisionConfiguration();

		long seed = config.getLong("random_seed", 42L);
		boolean varySeedByIteration = config.getInt("vary_seed_by_iteration", 1) == 1;
		this.effectiveSeed = varySeedByIteration ? seed + (iterationNumber * 1000003L) : seed;
		this.workloadRandom = new Random(effectiveSeed);
		this.policyRandom = new Random(effectiveSeed + 7919L);

		double[] rates = config.getDoubleArray("poisson_rates", new double[] {1.0, 2.0, 3.0});
		int nodeCount = config.getInt("node_count", rates.length);
		if (rates.length != nodeCount) {
			throw new IllegalArgumentException("poisson_rates count must match node_count.");
		}

		this.nodes = new EdgeNodeQueue[nodeCount];
		this.poissonMeans = new double[nodeCount];
		for (int i = 0; i < nodeCount; i++) {
			nodes[i] = new EdgeNodeQueue(i, rates[i]);
			poissonMeans[i] = rates[i] * arrivalTickSeconds;
		}

		double[][] defaultPairwise = new double[][] {
				{1.0, 3.0, 5.0, 0.5},
				{1.0 / 3.0, 1.0, 2.0, 0.25},
				{1.0 / 5.0, 0.5, 1.0, 0.2},
				{2.0, 4.0, 5.0, 1.0}
		};
		this.selector = new AhpRoughSetSelector(config.getMatrix("ahp_pairwise_matrix", defaultPairwise));
	}

	@Override
	public void startEntity() {
		try {
			openLogs();
		}
		catch (IOException e) {
			throw new RuntimeException("Cannot open output logs.", e);
		}
		printRunConfiguration();
		schedule(getId(), 0, ARRIVAL_TICK);
		schedule(getId(), simulationTime, STOP_SIMULATION);
	}

	@Override
	public void processEvent(SimEvent event) {
		switch (event.getTag()) {
		case ARRIVAL_TICK:
			processArrivalTick();
			break;
		case FINISH_TASK:
			finishTask((TaskVector) event.getData());
			break;
		case STOP_SIMULATION:
			writeSummary();
			CloudSim.terminateSimulation();
			break;
		default:
			throw new IllegalArgumentException("Unknown event tag: " + event.getTag());
		}
	}

	@Override
	public void shutdownEntity() {
		if (taskLog != null) {
			taskLog.close();
		}
		if (nodeLog != null) {
			nodeLog.close();
		}
	}

	private void processArrivalTick() {
		double now = CloudSim.clock();
		for (int i = 0; i < nodes.length; i++) {
			EdgeNodeQueue node = nodes[i];
			int arrivals = samplePoisson(poissonMeans[i]);
			for (int j = 0; j < arrivals; j++) {
				TaskVector task = createTask(node.id, now);
				node.enqueue(task);
				logTask("ARRIVED", task, node.id, "");
			}

			double observedRate = node.consumeObservedArrivalRate(arrivalTickSeconds);
			double smoothedRate = node.updateSmoothedArrivalRate(observedRate, arrivalEwmaAlpha);
			if (node.isIdle()) {
				startNextTask(node, observedRate);
			}

			double predictedQueue = node.predictedQueueSize(predictionHorizon, estimatedServiceRate);
			double proactiveQueueThreshold = Math.max(proactiveMinQueueThreshold,
					node.poissonRate * predictionHorizon * proactiveQueueMultiplier);
			boolean deadlineRisk = node.hasPredictedDeadlineRisk(now, expectedDelayFactor);
			boolean arrivalSurge = smoothedRate >= getEffectiveThreshold(node);
			boolean proactiveRisk = arrivalSurge &&
					(predictedQueue >= proactiveQueueThreshold || deadlineRisk);
			if (decisionMode.equals("PROACTIVE") && !offloadingPolicy.equals("NONE") &&
					node.waitingSize() > 0 && node.canOffload(now, offloadCooldown) && proactiveRisk) {
				offloadWaitingTasks(node, observedRate, "PROACTIVE", predictedQueue, deadlineRisk);
			}

			nodeLog.printf(Locale.US, "%.3f,%d,%.3f,%.3f,%d,%s,%.3f,%.3f,%s%n",
					now, node.id, observedRate, smoothedRate, node.waitingSize(), node.isIdle(),
					predictedQueue, proactiveQueueThreshold, proactiveRisk);
		}

		if (now + arrivalTickSeconds <= simulationTime) {
			schedule(getId(), arrivalTickSeconds, ARRIVAL_TICK);
		}
	}

	private void startNextTask(EdgeNodeQueue node, double observedArrivalRate) {
		TaskVector task = node.pollNextTask();
		if (task == null) {
			return;
		}

		task.currentNodeId = node.id;
		task.startTime = CloudSim.clock();
		if (task.delayed) {
			delayedTasks++;
		}

		logTask("STARTED", task, node.id, String.format(Locale.US, "observed_rate=%.3f", observedArrivalRate));

		double effectiveThreshold = getEffectiveThreshold(node);
		boolean allowReactiveTrigger = decisionMode.equals("REACTIVE") || reactiveFallbackEnabled;
		if (allowReactiveTrigger && !offloadingPolicy.equals("NONE") &&
				task.delayed && observedArrivalRate >= effectiveThreshold && node.waitingSize() > 0 &&
				node.canOffload(CloudSim.clock(), offloadCooldown)) {
			offloadWaitingTasks(node, observedArrivalRate, "REACTIVE", node.waitingSize(), false);
		}

		schedule(getId(), task.actualExecutionTime(), FINISH_TASK, task);
	}

	private double getEffectiveThreshold(EdgeNodeQueue node) {
		if (thresholdMode.equals("FIXED")) {
			return highArrivalRateThreshold;
		}
		else if (thresholdMode.equals("ADAPTIVE_RATE")) {
			return node.poissonRate * thresholdMultiplier;
		}
		else {
			throw new IllegalArgumentException("Unknown threshold_mode: " + thresholdMode);
		}
	}

	private void finishTask(TaskVector task) {
		double now = CloudSim.clock();
		EdgeNodeQueue node = nodes[task.currentNodeId];
		task.finishTime = now;
		completedTasks++;
		if (task.wasOffloaded) {
			completedOffloadedTasks++;
		}
		if (now > task.deadline) {
			completedDeadlineMisses++;
		}
		node.clearRunningTask();
		logTask("FINISHED", task, node.id, "");

		startNextTask(node, node.getLastObservedArrivalRate());
	}

	private void offloadWaitingTasks(EdgeNodeQueue node, double observedArrivalRate,
			String triggerType, double predictedQueue, boolean deadlineRisk) {
		int offloadLimit = Math.min(maxOffloadsPerEvent,
				Math.max(1, (int) Math.ceil(node.waitingSize() * offloadFraction)));
		List<TaskVector> selectedTasks = selectWaitingTasks(
				eligibleWaitingTasks(node.waitingSnapshot()), offloadLimit);
		if (selectedTasks.isEmpty()) {
			return;
		}
		node.removeWaitingTasks(selectedTasks);
		offloadedTasks += selectedTasks.size();
		node.markOffload(CloudSim.clock());
		if (triggerType.equals("PROACTIVE")) {
			proactiveTriggerEvents++;
		}
		else {
			reactiveTriggerEvents++;
		}

		for (int i = 0; i < selectedTasks.size(); i++) {
			TaskVector task = selectedTasks.get(i);
			task.offloadCount++;
			int destinationNodeId = -1;
			if (offloadDestinationPolicy.equals("LEAST_QUEUE")) {
				destinationNodeId = selectLeastQueueDestination(node.id);
				transferOffloadedTask(task, destinationNodeId);
			}
			else if (offloadDestinationPolicy.equals("MIN_ESTIMATED_DELAY")) {
				destinationNodeId = selectMinEstimatedDelayDestination(node.id);
				transferOffloadedTask(task, destinationNodeId);
			}
			else if (!offloadDestinationPolicy.equals("DROP")) {
				throw new IllegalArgumentException("Unknown offload_destination_policy: " + offloadDestinationPolicy);
			}

			logTask("OFFLOADED", task, node.id,
					String.format(Locale.US, "trigger=%s;observed_rate=%.3f;smoothed_rate=%.3f;predicted_queue=%.3f;deadline_risk=%s;decision_score=%.6f;offload_count=%d;destination_node=%d;destination_policy=%s",
							triggerType, observedArrivalRate, node.getSmoothedArrivalRate(), predictedQueue,
							deadlineRisk, task.roughScore, task.offloadCount, destinationNodeId, offloadDestinationPolicy));

			if (destinationNodeId >= 0) {
				logTask("RECEIVED_OFFLOAD", task, destinationNodeId,
						String.format(Locale.US, "source_node=%d;rough_score=%.6f",
								node.id, task.roughScore));
				if (nodes[destinationNodeId].isIdle()) {
					startNextTask(nodes[destinationNodeId], nodes[destinationNodeId].getLastObservedArrivalRate());
				}
			}
		}
	}

	private void transferOffloadedTask(TaskVector task, int destinationNodeId) {
		task.wasOffloaded = true;
		task.currentNodeId = destinationNodeId;
		nodes[destinationNodeId].enqueueOffloaded(task);
		receivedOffloadedTasks++;
	}

	private int selectLeastQueueDestination(int sourceNodeId) {
		int selectedNodeId = -1;
		int selectedQueueSize = Integer.MAX_VALUE;
		for (int i = 0; i < nodes.length; i++) {
			if (i == sourceNodeId) {
				continue;
			}
			int queueSize = nodes[i].waitingSize();
			if (queueSize < selectedQueueSize) {
				selectedNodeId = i;
				selectedQueueSize = queueSize;
			}
		}
		if (selectedNodeId < 0) {
			throw new IllegalStateException("No destination node is available for offloading.");
		}
		return selectedNodeId;
	}

	private int selectMinEstimatedDelayDestination(int sourceNodeId) {
		int selectedNodeId = -1;
		double selectedBacklogTime = Double.MAX_VALUE;
		double now = CloudSim.clock();
		for (int i = 0; i < nodes.length; i++) {
			if (i == sourceNodeId) {
				continue;
			}
			double backlogTime = nodes[i].estimatedBacklogTime(now);
			if (backlogTime < selectedBacklogTime) {
				selectedNodeId = i;
				selectedBacklogTime = backlogTime;
			}
		}
		if (selectedNodeId < 0) {
			throw new IllegalStateException("No destination node is available for offloading.");
		}
		return selectedNodeId;
	}

	private List<TaskVector> selectWaitingTasks(List<TaskVector> waitingTasks, int offloadLimit) {
		if (offloadingPolicy.equals("AHP_ROUGH")) {
			return selector.selectTasksToOffload(waitingTasks, offloadLimit);
		}
		else if (offloadingPolicy.equals("RANDOM")) {
			return selector.selectRandomTasks(waitingTasks, offloadLimit, policyRandom);
		}
		else if (offloadingPolicy.equals("FIFO")) {
			return selector.selectFifoTasks(waitingTasks, offloadLimit);
		}
		else {
			throw new IllegalArgumentException("Unknown offloading_policy: " + offloadingPolicy);
		}
	}

	private List<TaskVector> eligibleWaitingTasks(List<TaskVector> waitingTasks) {
		List<TaskVector> eligibleTasks = new ArrayList<TaskVector>();
		for (int i = 0; i < waitingTasks.size(); i++) {
			TaskVector task = waitingTasks.get(i);
			if (task.offloadCount < maxTaskOffloads) {
				eligibleTasks.add(task);
			}
		}
		return eligibleTasks;
	}

	private TaskVector createTask(int nodeId, double now) {
		int priority = minPriority + workloadRandom.nextInt(maxPriority - minPriority + 1);
		int steps = minSteps + workloadRandom.nextInt(maxSteps - minSteps + 1);
		double complexity = minComplexity + workloadRandom.nextDouble() * (maxComplexity - minComplexity);
		double deadline = now + minDeadlineSlack + workloadRandom.nextDouble() * (maxDeadlineSlack - minDeadlineSlack);
		double executionTime = minExecutionTime + workloadRandom.nextDouble() * (maxExecutionTime - minExecutionTime);
		TaskVector task = new TaskVector(nextTaskId++, nodeId, now, priority, steps, complexity, deadline, executionTime);
		if (workloadRandom.nextDouble() < delayProbability) {
			task.delayed = true;
			task.delayMultiplier = minDelayMultiplier + workloadRandom.nextDouble() * (maxDelayMultiplier - minDelayMultiplier);
		}
		return task;
	}

	private int samplePoisson(double mean) {
		double limit = Math.exp(-mean);
		int count = 0;
		double product = 1.0;
		do {
			count++;
			product *= workloadRandom.nextDouble();
		}
		while (product > limit);
		return count - 1;
	}

	private void openLogs() throws IOException {
		File folder = new File(outputFolder);
		if (!folder.exists() && !folder.mkdirs()) {
			throw new IOException("Cannot create output folder: " + outputFolder);
		}

		taskLog = new PrintWriter(new FileWriter(new File(folder, "task_events.csv")));
		taskLog.println("time,event,task_id,node_id,priority,steps,complexity,deadline,base_execution_time,delay_multiplier,rough_score,details");

		nodeLog = new PrintWriter(new FileWriter(new File(folder, "node_state.csv")));
		nodeLog.println("time,node_id,observed_arrival_rate,smoothed_arrival_rate,waiting_queue_size,idle,predicted_queue_size,proactive_queue_threshold,proactive_risk");
	}

	private void printRunConfiguration() {
		double[] weights = selector.getWeights();
		System.out.printf(Locale.US, "Policy: %s, decision_mode=%s, destination=%s, threshold_mode=%s, effective_seed=%d%n",
				offloadingPolicy, decisionMode, offloadDestinationPolicy, thresholdMode, effectiveSeed);
		System.out.printf(Locale.US,
				"AHP weights: priority=%.4f, steps=%.4f, complexity=%.4f, deadline=%.4f%n",
				weights[0], weights[1], weights[2], weights[3]);
	}

	private void logTask(String event, TaskVector task, int nodeId, String details) {
		taskLog.printf(Locale.US, "%.3f,%s,%d,%d,%d,%d,%.3f,%.3f,%.3f,%.3f,%.6f,%s%n",
				CloudSim.clock(), event, task.id, nodeId, task.priority, task.steps,
				task.complexity, task.deadline, task.baseExecutionTime, task.delayMultiplier,
				task.roughScore, details);
	}

	private void writeSummary() {
		File folder = new File(outputFolder);
		PrintWriter summary = null;
		try {
			summary = new PrintWriter(new FileWriter(new File(folder, "summary.txt")));
			summary.println("AHP + rough-set-inspired queue scenario");
			summary.println("offloading_policy=" + offloadingPolicy);
			summary.println("decision_mode=" + decisionMode);
			summary.println("offload_destination_policy=" + offloadDestinationPolicy);
			summary.println("threshold_mode=" + thresholdMode);
			summary.println("threshold_multiplier=" + thresholdMultiplier);
			summary.println("effective_seed=" + effectiveSeed);
			summary.println("simulation_time=" + simulationTime);
			summary.println("nodes=" + nodes.length);
			summary.println("high_arrival_rate_threshold=" + highArrivalRateThreshold);
			summary.println("offload_fraction=" + offloadFraction);
			summary.println("max_offloads_per_event=" + maxOffloadsPerEvent);
			summary.println("max_task_offloads=" + maxTaskOffloads);
			summary.println("arrival_ewma_alpha=" + arrivalEwmaAlpha);
			summary.println("prediction_horizon_seconds=" + predictionHorizon);
			summary.println("proactive_queue_multiplier=" + proactiveQueueMultiplier);
			summary.println("proactive_min_queue_threshold=" + proactiveMinQueueThreshold);
			summary.println("offload_cooldown_seconds=" + offloadCooldown);
			summary.println("reactive_fallback_enabled=" + reactiveFallbackEnabled);
			summary.println("estimated_service_rate=" + estimatedServiceRate);
			summary.println("generated_tasks=" + (nextTaskId - 1));
			summary.println("completed_tasks=" + completedTasks);
			summary.println("delayed_tasks=" + delayedTasks);
			summary.println("offloaded_tasks=" + offloadedTasks);
			summary.println("received_offloaded_tasks=" + receivedOffloadedTasks);
			summary.println("completed_offloaded_tasks=" + completedOffloadedTasks);
			summary.println("proactive_trigger_events=" + proactiveTriggerEvents);
			summary.println("reactive_trigger_events=" + reactiveTriggerEvents);
			summary.println("completed_deadline_misses=" + completedDeadlineMisses);
			summary.println("completed_before_deadline=" + (completedTasks - completedDeadlineMisses));
			int totalWaitingTasks = 0;
			int minWaitingTasks = Integer.MAX_VALUE;
			int maxWaitingTasks = 0;
			for (int i = 0; i < nodes.length; i++) {
				totalWaitingTasks += nodes[i].waitingSize();
				minWaitingTasks = Math.min(minWaitingTasks, nodes[i].waitingSize());
				maxWaitingTasks = Math.max(maxWaitingTasks, nodes[i].waitingSize());
				summary.println("node_" + i + "_waiting_tasks=" + nodes[i].waitingSize());
			}
			summary.println("total_waiting_tasks=" + totalWaitingTasks);
			summary.println("queue_imbalance=" + (maxWaitingTasks - minWaitingTasks));
		}
		catch (IOException e) {
			throw new RuntimeException("Cannot write summary.", e);
		}
		finally {
			if (summary != null) {
				summary.close();
			}
		}
	}

	private void validateDecisionConfiguration() {
		if (!decisionMode.equals("REACTIVE") && !decisionMode.equals("PROACTIVE")) {
			throw new IllegalArgumentException("decision_mode must be REACTIVE or PROACTIVE.");
		}
		if (arrivalEwmaAlpha <= 0.0 || arrivalEwmaAlpha > 1.0) {
			throw new IllegalArgumentException("arrival_ewma_alpha must be in (0, 1].");
		}
		if (predictionHorizon <= 0.0 || proactiveQueueMultiplier <= 0.0 ||
				proactiveMinQueueThreshold < 0.0 || offloadCooldown < 0.0) {
			throw new IllegalArgumentException("Proactive prediction parameters must be non-negative and the horizon/multiplier must be positive.");
		}
		if (maxTaskOffloads <= 0) {
			throw new IllegalArgumentException("max_task_offloads must be positive.");
		}
	}
}
