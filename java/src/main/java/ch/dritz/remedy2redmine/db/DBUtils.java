package ch.dritz.remedy2redmine.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.logging.Logger;

import ch.dritz.common.Config;

/**
 * Helper to get Database connections
 * @author D.Ritz
 */
public class DBUtils
{
	private static final Logger log = Logger.getLogger(DBUtils.class.getPackage().getName());

	public static Connection getConnection(Config config, String connectionName, boolean autocommit)
	{
		try {
			String configPrefix = "db." + connectionName + ".";
			String driver = config.getString(configPrefix + "driver", "no driver specified");
			Class.forName(driver);

			Properties props = new Properties();
			props.setProperty("user", config.getString(configPrefix + "user", ""));
			props.setProperty("password", config.getString(configPrefix + "pass", ""));

			String url = config.getString(configPrefix + "url", "no url specified");

			Connection conn = DriverManager.getConnection(url, props);
			conn.setAutoCommit(autocommit);
			return conn;

		} catch (RuntimeException e) {
			throw e;
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	/**
	 * closes a statement
	 * @param stmt the statement
	 */
	public static void closeStatement(Statement stmt)
	{
		if (stmt == null)
			return;
		try {
			stmt.close();
		} catch (SQLException e) {
			log.warning("close Statement failed: " + e);
		}
	}


	/**
	 * closes a result set, ignoring any exception
	 * @param rs the ResultSet to close
	 */
	public static void closeResultSet(ResultSet rs)
	{
		if (rs == null)
			return;
		try {
			rs.close();
		} catch (SQLException e) {
			log.warning("close ResultSet failed: " + e);
		}
	}

	/**
	 * closes a connection, ignoring any exception
	 * @param conn the Connection to close
	 */
	public static void closeConnection(Connection conn)
	{
		if (conn == null)
			return;
		try {
			conn.close();
		} catch (SQLException e) {
			log.warning("close Connection failed: " + e);
		}
	}
}
