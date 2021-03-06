package ch.dritz.remedy2redmine.modules;

import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import org.mozilla.universalchardet.UniversalDetector;

import ch.dritz.common.Config;
import ch.dritz.remedy2redmine.db.DBUtils;

/**
 * Module to sync Remedy to Redmine
 * @author D.Ritz
 */
public class SyncModule
{
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

	private UniversalDetector charsetDetector = new UniversalDetector(null);

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
		ColumnDefinition lastChangeTs = null;
		List<ColumnDefinition> keyColumns = new ArrayList<ColumnDefinition>();
		for (ColumnDefinition col : colDefinitions) {
			if (col.isKey) {
				keyColumns.add(col);
				continue;
			}
			if (col.isLastChangeTs)
				lastChangeTs = col;

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
		for (ColumnDefinition col : keyColumns) {
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

		int maxLastChangeTs = getMaxLastChangeTs(destTable, lastChangeTs);
		String filter = config.getString("sync.source.filter", "");
		StringBuilder sbWhere = new StringBuilder();
		sbWhere.append(filter);

		if (maxLastChangeTs > 0) {
			if (sbWhere.length() > 0)
				sbWhere.append(" AND ");
			sbWhere.append(lastChangeTs.source).append(" >= ").append(maxLastChangeTs);
		}

		if (sbWhere.length() > 0)
			sbRead.append(" WHERE ").append(sbWhere);

		stmtRead = dbRemedy.prepareStatement(sbRead.toString());
		stmtInsert = dbRedmine.prepareStatement(sbInsert.toString());
		stmtUpdate = dbRedmine.prepareStatement(sbUpdate.toString());
		stmtCheck = dbRedmine.prepareStatement(sbCheck.toString());
	}

	private int getMaxLastChangeTs(String table, ColumnDefinition col)
		throws SQLException
	{
		if (col == null)
			return 0;
		int ret = 0;

		PreparedStatement stmt = dbRedmine.prepareStatement(
			"SELECT MAX(" + col.target + ") FROM " + table);
		try {
			ResultSet rs = stmt.executeQuery();
			if (rs.next()) {
				Timestamp ts = rs.getTimestamp(1);
				ret = (int) (ts.getTime() / 1000L);
			}
			rs.close();
		} finally {
			stmt.close();
		}

		return ret;
	}

	private boolean existsInTarget(ResultSet rs)
		throws SQLException
	{
		for (int in = numCols - numKeys + 1, out = 1; in <= numCols; in++, out++) {
			Object obj = rs.getObject(in);
			stmtCheck.setObject(out, obj);
		}

		ResultSet rsCheck = stmtCheck.executeQuery();
		boolean exists = rsCheck.next();
		rsCheck.close();

		return exists;
	}

	private void sync()
		throws SQLException
	{
		ResultSet rs = stmtRead.executeQuery();

		int num = 0;
		while (rs.next()) {
			PreparedStatement stmtInsertOrUpdate;
			if (existsInTarget(rs))
				stmtInsertOrUpdate = stmtUpdate;
			else
				stmtInsertOrUpdate = stmtInsert;

			// insert or update
			for (int i = 1; i <= numCols; i++) {
				Object obj = convert(rs, i, conversions[i-1]);
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

	private Object convert(ResultSet rs, int i, Conversion conversion)
		throws SQLException
	{
		if (conversion == Conversion.FIXCHARSET) {
			byte[] bytes = rs.getBytes(i);
			if (bytes == null)
				return null;
			charsetDetector.handleData(bytes, 0, bytes.length);
			charsetDetector.dataEnd();
			String encoding = charsetDetector.getDetectedCharset();
			charsetDetector.reset();
			try {
				if (encoding != null)
					return new String(bytes, encoding);
			} catch (UnsupportedEncodingException e) {
			}
			return rs.getObject(i);
		}

		Object obj = rs.getObject(i);
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
		FIXCHARSET,
	}

	private static class ColumnDefinition
	{
		String source;
		String target;
		Conversion conversion = Conversion.NONE;
		boolean isKey;
		boolean isLastChangeTs;

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
					else if ("LastChangeTimestamp".equals(attr))
						isLastChangeTs = true;
					else if ("FixCharset".equals(attr))
						conversion = Conversion.FIXCHARSET;
				}
			}
		}
	}
}
