/*
 * Main entry point for the AHP + rough sets queue scenario.
 */
package edu.boun.edgecloudsim.applications.ahp_rough;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import org.cloudbus.cloudsim.Log;
import org.cloudbus.cloudsim.core.CloudSim;

public class MainApp {
	public static void main(String[] args) {
		Log.disable();

		String configFile = "scripts/ahp_rough/config/default_config.properties";
		String outputFolder = "scripts/ahp_rough/output/manual";
		int iterationNumber = 1;

		if (args.length >= 1) {
			configFile = args[0];
		}
		if (args.length >= 2) {
			outputFolder = args[1];
		}
		if (args.length >= 3) {
			iterationNumber = Integer.parseInt(args[2]);
		}

		DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
		Date startDate = Calendar.getInstance().getTime();
		System.out.println("AHP + Rough Sets simulation started at " + df.format(startDate));
		System.out.println("Config: " + configFile);
		System.out.println("Output: " + outputFolder);
		System.out.println("Iteration: " + iterationNumber);

		try {
			ScenarioConfig config = ScenarioConfig.load(configFile);
			int numUser = 1;
			Calendar calendar = Calendar.getInstance();
			boolean traceFlag = false;
			CloudSim.init(numUser, calendar, traceFlag, 0.01);

			new AhpRoughSimulation(config, outputFolder, iterationNumber);
			CloudSim.startSimulation();
			CloudSim.stopSimulation();
		}
		catch (Exception e) {
			System.err.println("Simulation terminated due to an error.");
			e.printStackTrace();
			System.exit(1);
		}

		Date endDate = Calendar.getInstance().getTime();
		System.out.println("AHP + Rough Sets simulation finished at " + df.format(endDate));
	}
}
