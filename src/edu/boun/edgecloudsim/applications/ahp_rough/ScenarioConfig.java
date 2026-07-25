/*
 * Application-level configuration for the AHP + rough sets queue scenario.
 */
package edu.boun.edgecloudsim.applications.ahp_rough;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

class ScenarioConfig {
	private final Properties properties = new Properties();

	private ScenarioConfig(String path) throws IOException {
		FileInputStream input = new FileInputStream(path);
		try {
			properties.load(input);
		}
		finally {
			input.close();
		}
	}

	static ScenarioConfig load(String path) throws IOException {
		return new ScenarioConfig(path);
	}

	int getInt(String key, int defaultValue) {
		String value = properties.getProperty(key);
		return value == null ? defaultValue : Integer.parseInt(value.trim());
	}

	long getLong(String key, long defaultValue) {
		String value = properties.getProperty(key);
		return value == null ? defaultValue : Long.parseLong(value.trim());
	}

	double getDouble(String key, double defaultValue) {
		String value = properties.getProperty(key);
		return value == null ? defaultValue : Double.parseDouble(value.trim());
	}

	String getString(String key, String defaultValue) {
		String value = properties.getProperty(key);
		return value == null ? defaultValue : value.trim();
	}

	double[] getDoubleArray(String key, double[] defaultValue) {
		String value = properties.getProperty(key);
		if (value == null || value.trim().isEmpty()) {
			return defaultValue;
		}

		String[] parts = value.split(",");
		double[] result = new double[parts.length];
		for (int i = 0; i < parts.length; i++) {
			result[i] = Double.parseDouble(parts[i].trim());
		}
		return result;
	}

	double[][] getMatrix(String key, double[][] defaultValue) {
		String value = properties.getProperty(key);
		if (value == null || value.trim().isEmpty()) {
			return defaultValue;
		}

		String[] rows = value.split("\\|");
		double[][] matrix = new double[rows.length][];
		for (int i = 0; i < rows.length; i++) {
			String[] columns = rows[i].split(",");
			matrix[i] = new double[columns.length];
			for (int j = 0; j < columns.length; j++) {
				matrix[i][j] = Double.parseDouble(columns[j].trim());
			}
		}
		return matrix;
	}
}
