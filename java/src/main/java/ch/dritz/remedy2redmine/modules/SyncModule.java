package ch.dritz.remedy2redmine.modules;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import ch.dritz.common.Config;
import ch.dritz.remedy2redmine.db.DBUtils;

/**
 * Module to sync Remedy to Redmine
 * @author D.Ritz
 */
public class SyncModule
{
	private static final Logger log = Logger.getLogger(SyncModule.class.getPackage().getName());

	private Config config;
	private Connection dbRemedy;
	private Connection dbRedmine;

	private PreparedStatement stmtRead;
	private PreparedStatement stmtInsert;
	private PreparedStatement stmtUpdate;
	private PreparedStatement stmtCheck;

	private int numCols;
	private int numKeys;
	private Conversion[] conversions;

	public SyncModule(Config config)
	{
		this.config = config;
	}

	public void start()
		throws SQLException
	{
		dbRedmine = DBUtils.getConnection(config, "redmine", false);
		dbRemedy  = DBUtils.getConnection(config, "remedy", true);

		prepareStatements();
		sync();
		cleanup();
	}

	public void shutdown()
	{
		DBUtils.closeConnection(dbRedmine);
		DBUtils.closeConnection(dbRemedy);
	}

	private void prepareStatements()
		throws SQLException
	{
		// parse
		String[] columns = config.getStringArray("sync.cols");
		List<ColumnDefinition> colDefinitions = new ArrayList<ColumnDefinition>();
		for (String col : columns)
			colDefinitions.add(new ColumnDefinition(col));

		// setup....
		String sourceTable = config.getString("sync.source.table", "source_table");
		String destTable = config.getString("sync.dest.table", "dest_table");

		StringBuilder sbRead = new StringBuilder();
		StringBuilder sbInsert = new StringBuilder();
		StringBuilder sbInsertBinds = new StringBuilder();
		StringBuilder sbUpdate = new StringBuilder();
		StringBuilder sbCheck = new StringBuilder();

		sbRead.append("SELECT ");
		sbInsert.append("INSERT INTO ").append(destTable).append(" (");
		sbUpdate.append("UPDATE ").append(destTable).append(" SET ");
		sbCheck.append("SELECT 1 FROM ").append(destTable).append(" WHERE ");

		numCols = 0;
		numKeys = 0;
		conversions = new Conversion[columns.length];

		// pass 1: normal columns
		for (ColumnDefinition col : colDefinitions) {
			if (col.isKey)
				continue;

			if (numCols > 0) {
				sbRead.append(", ");
				sbInsert.append(", ");
				sbInsertBinds.append(", ");
				sbUpdate.append(", ");
			}

			sbRead.append(col.source);
			sbInsert.append(col.target);
			sbInsertBinds.append("?");
			sbUpdate.append(col.target).append(" = ?");

			conversions[numCols] = col.conversion;
			numCols++;
		}

		sbUpdate.append(" WHERE ");

		// pass 2: key columns
		for (ColumnDefinition col : colDefinitions) {
			if (!col.isKey)
				continue;

			if (numCols > 0) {
				sbRead.append(", ");
				sbInsert.append(", ");
				sbInsertBinds.append(", ");
			}

			sbRead.append(col.source);
			sbInsert.append(col.target);
			sbInsertBinds.append("?");

			if (numKeys > 0) {
				sbUpdate.append(" AND ");
				sbCheck.append(" AND ");
			}
			sbUpdate.append(col.target).append(" = ?");
			sbCheck.append(col.target).append(" = ?");

			conversions[numCols] = col.conversion;
			numCols++;
			numKeys++;
		}

		sbRead.append(" FROM ").append(sourceTable);
		sbInsert.append(") VALUES (").append(sbInsertBinds.toString()).append(")");

		String condition = config.getString("sync.source.filter", null);
		if (condition != null)
			sbRead.append(" WHERE ").append(condition);

		if (log.isLoggable(Level.FINE)) {
			log.fine(sbRead.toString());
			log.fine(sbInsert.toString());
			log.fine(sbUpdate.toString());
			log.fine(sbCheck.toString());
		}

		stmtRead = dbRemedy.prepareStatement(sbRead.toString());
		stmtInsert = dbRedmine.prepareStatement(sbInsert.toString());
		stmtUpdate = dbRedmine.prepareStatement(sbUpdate.toString());
		stmtCheck = dbRedmine.prepareStatement(sbCheck.toString());
	}

	private void sync()
		throws SQLException
	{
		ResultSet rs = stmtRead.executeQuery();

		int num = 0;
		while (rs.next()) {
			// check if exists
			StringBuilder sb = new StringBuilder();
			for (int in = numCols - numKeys + 1, out = 1; in <= numCols; in++, out++) {
				Object obj = rs.getObject(in);
				stmtCheck.setObject(out, obj);
				sb.append(obj).append(" ");
			}

			PreparedStatement stmtInsertOrUpdate = null;
			ResultSet rsCheck = stmtCheck.executeQuery();
			if (rsCheck.next()) {
				stmtInsertOrUpdate = stmtUpdate;

				if (log.isLoggable(Level.FINE))
					log.fine("Updating: " + sb);
			} else {
				stmtInsertOrUpdate = stmtInsert;

				if (log.isLoggable(Level.FINE))
					log.fine("Inserting: " + sb);
			}
			rsCheck.close();

			// insert or update
			for (int i = 1; i <= numCols; i++) {
				Object obj = convert(rs.getObject(i), conversions[i-1]);
				stmtInsertOrUpdate.setObject(i, obj);
			}

			stmtInsertOrUpdate.addBatch();
			if (++num % 100 == 0) {
				stmtInsert.executeBatch();
				stmtUpdate.executeBatch();
			}
		}
		stmtInsert.executeBatch();
		stmtUpdate.executeBatch();

		rs.close();
	}

	private Object convert(Object obj, Conversion conversion)
	{
		if (obj == null)
			return null;

		switch (conversion) {
		case TIMESTAMP:
			return new Timestamp(((Number) obj).intValue() * 1000L);

		case CHAR_TO_INT:
			try {
				return Integer.parseInt(obj.toString());
			} catch (NumberFormatException e) {
				return 0;
			}
		default:
			return obj;
		}
	}

	private void cleanup()
		throws SQLException
	{
		DBUtils.closeStatement(stmtCheck);
		DBUtils.closeStatement(stmtUpdate);
		DBUtils.closeStatement(stmtInsert);
		DBUtils.closeStatement(stmtRead);
		dbRedmine.commit();
	}

	private static enum Conversion
	{
		NONE,
		TIMESTAMP,
		CHAR_TO_INT,
	}

	private static class ColumnDefinition
	{
		String source;
		String target;
		Conversion conversion = Conversion.NONE;
		boolean isKey;

		public ColumnDefinition(String defString)
		{
			String[] definition = defString.split(":", 2);

			String[] tmp = definition[0].split(",", 2);
			source = tmp[0];
			target = tmp.length == 2 ? tmp[1] : tmp[0];

			if (definition.length == 2) {
				String[] attrString = definition[1].split(",");
				for (String attr : attrString) {
					if ("Key".equals(attr))
						isKey = true;
					else if ("Timestamp".equals(attr))
						conversion = Conversion.TIMESTAMP;
					else if ("CharToInt".equals(attr))
						conversion = Conversion.CHAR_TO_INT;
				}
			}
		}
	}
}
