/*
 * AHP weighting plus rough-set-inspired task ranking.
 */
package edu.boun.edgecloudsim.applications.ahp_rough;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Random;

class AhpRoughSetSelector {
	private final double[] weights;

	AhpRoughSetSelector(double[][] pairwiseMatrix) {
		validateMatrix(pairwiseMatrix);
		this.weights = calculateAhpWeights(pairwiseMatrix);
	}

	double[] getWeights() {
		double[] copy = new double[weights.length];
		System.arraycopy(weights, 0, copy, 0, weights.length);
		return copy;
	}

	List<TaskVector> selectTasksToOffload(List<TaskVector> waitingTasks, int maxTasks) {
		if (waitingTasks.isEmpty() || maxTasks <= 0) {
			return Collections.emptyList();
		}

		double[][] normalized = normalize(waitingTasks);
		double[] rawScores = new double[waitingTasks.size()];
		for (int i = 0; i < waitingTasks.size(); i++) {
			rawScores[i] =
					weights[0] * normalized[i][0] +
					weights[1] * normalized[i][1] +
					weights[2] * normalized[i][2] +
					weights[3] * normalized[i][3];
		}

		double mean = mean(rawScores);
		double deviation = standardDeviation(rawScores, mean);
		double lowerApproximationLimit = mean + (0.5 * deviation);
		double boundaryLimit = mean;

		List<TaskVector> candidates = new ArrayList<TaskVector>();
		for (int i = 0; i < waitingTasks.size(); i++) {
			TaskVector task = waitingTasks.get(i);
			double roughMembership = rawScores[i] >= lowerApproximationLimit ? 1.0 :
					rawScores[i] >= boundaryLimit ? 0.5 : 0.0;
			task.roughScore = rawScores[i] + roughMembership;
			if (roughMembership > 0.0) {
				candidates.add(task);
			}
		}

		Collections.sort(candidates, new Comparator<TaskVector>() {
			@Override
			public int compare(TaskVector left, TaskVector right) {
				return Double.compare(right.roughScore, left.roughScore);
			}
		});

		int limit = Math.min(maxTasks, candidates.size());
		return new ArrayList<TaskVector>(candidates.subList(0, limit));
	}

	List<TaskVector> selectFifoTasks(List<TaskVector> waitingTasks, int maxTasks) {
		if (waitingTasks.isEmpty() || maxTasks <= 0) {
			return Collections.emptyList();
		}

		int limit = Math.min(maxTasks, waitingTasks.size());
		List<TaskVector> selectedTasks = new ArrayList<TaskVector>();
		for (int i = 0; i < limit; i++) {
			TaskVector task = waitingTasks.get(i);
			task.roughScore = 0.0;
			selectedTasks.add(task);
		}
		return selectedTasks;
	}

	List<TaskVector> selectRandomTasks(List<TaskVector> waitingTasks, int maxTasks, Random random) {
		if (waitingTasks.isEmpty() || maxTasks <= 0) {
			return Collections.emptyList();
		}

		List<TaskVector> shuffledTasks = new ArrayList<TaskVector>(waitingTasks);
		Collections.shuffle(shuffledTasks, random);
		int limit = Math.min(maxTasks, shuffledTasks.size());
		List<TaskVector> selectedTasks = new ArrayList<TaskVector>();
		for (int i = 0; i < limit; i++) {
			TaskVector task = shuffledTasks.get(i);
			task.roughScore = 0.0;
			selectedTasks.add(task);
		}
		return selectedTasks;
	}

	private static void validateMatrix(double[][] matrix) {
		if (matrix.length != 4) {
			throw new IllegalArgumentException("AHP pairwise matrix must have 4 rows.");
		}
		for (int i = 0; i < matrix.length; i++) {
			if (matrix[i].length != 4) {
				throw new IllegalArgumentException("AHP pairwise matrix must be 4x4.");
			}
		}
	}

	private static double[] calculateAhpWeights(double[][] matrix) {
		double[] columnSums = new double[4];
		for (int row = 0; row < 4; row++) {
			for (int col = 0; col < 4; col++) {
				columnSums[col] += matrix[row][col];
			}
		}

		double[] weights = new double[4];
		for (int row = 0; row < 4; row++) {
			double rowSum = 0;
			for (int col = 0; col < 4; col++) {
				rowSum += matrix[row][col] / columnSums[col];
			}
			weights[row] = rowSum / 4.0;
		}
		return weights;
	}

	private static double[][] normalize(List<TaskVector> tasks) {
		double[][] values = new double[tasks.size()][4];
		for (int i = 0; i < tasks.size(); i++) {
			TaskVector task = tasks.get(i);
			values[i][0] = task.priority;
			values[i][1] = task.steps;
			values[i][2] = task.complexity;
			values[i][3] = Math.max(0.001, task.deadline - task.arrivalTime);
		}

		for (int col = 0; col < 4; col++) {
			double min = Double.MAX_VALUE;
			double max = -Double.MAX_VALUE;
			for (int row = 0; row < values.length; row++) {
				min = Math.min(min, values[row][col]);
				max = Math.max(max, values[row][col]);
			}

			double range = max - min;
			for (int row = 0; row < values.length; row++) {
				if (range == 0) {
					values[row][col] = 1.0;
				}
				else if (col == 0) {
					values[row][col] = (values[row][col] - min) / range;
				}
				else {
					values[row][col] = (max - values[row][col]) / range;
				}
			}
		}
		return values;
	}

	private static double mean(double[] values) {
		double sum = 0;
		for (int i = 0; i < values.length; i++) {
			sum += values[i];
		}
		return sum / values.length;
	}

	private static double standardDeviation(double[] values, double mean) {
		double sum = 0;
		for (int i = 0; i < values.length; i++) {
			double diff = values[i] - mean;
			sum += diff * diff;
		}
		return Math.sqrt(sum / values.length);
	}
}
