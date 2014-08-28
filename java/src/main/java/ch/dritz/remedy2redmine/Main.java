package ch.dritz.remedy2redmine;

import java.io.File;
import java.io.IOException;

import ch.dritz.common.Config;
import ch.dritz.remedy2redmine.modules.SyncModule;


/**
 * Main class for Remedy2Redmine
 * @author D.Ritz
 */
public class Main
{
	private static void usage(String msg)
	{
		if (msg != null)
			System.out.println("ERROR: " + msg);
		System.out.println("Remedy2Redmine " + Version.getVersion());
		System.out.println("Usage: Remedy2Redmine <config.properties> <command> <command specific args>");
		System.out.println("  <command>   : one of sync");
		System.out.println("  <mode specific args> for each mode:");
		System.out.println("OR: Remedy2Redmine -version");
		System.exit(1);
	}

	/**
	 * main() entry point
	 * @param args
	 * @throws IOException
	 */
	public static void main(String[] args)
		throws Exception
	{
		if (args.length == 1 && "-version".equals(args[0])) {
			System.out.println("Remedy2Redmine " + Version.getVersion());
			return;
		}

		if (args.length < 2)
			usage("Not enough arguments");

		File configFile = new File(args[0]);
		String command = args[1];

		Config config = new Config();
		config.loadFromFile(configFile);

		if ("sync".equals(command)) {
			File syncConfig = new File(configFile.getParentFile(),
				config.getString("sync.config", "sync.properties"));
			config.loadFromFile(syncConfig);

			SyncModule sync = new SyncModule(config);
			try {
				sync.start();
			} finally {
				sync.shutdown();
			}
		} else {
			usage("Unknown command");
		}
	}
}
