package ch.dritz.common;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

/**
 * Convenience wrapper around Properties
 * @author D.Ritz
 */
public class Config
	extends Properties
{
	private static final long serialVersionUID = 1L;

	public void loadFromFile(File file)
		throws IOException
	{
		FileInputStream fs = null;
		try {
			fs = new FileInputStream(file);
			load(fs);
		} finally {
			if (fs != null) {
				try {
					fs.close();
				} catch (IOException e) {
				}
			}
		}
	}

	public void save(File file)
		throws IOException
	{
		FileOutputStream os = new FileOutputStream(file);
		try {
			store(os, "");
		} finally {
			os.close();
		}
	}

	public String getString(String key, String def)
	{
		return getProperty(key, def);
	}

	public void setString(String key, String val)
	{
		setProperty(key, val);
	}

	public int getInt(String key, int def)
	{
		String val = getProperty(key);
		if (val != null)
			try {
				return Integer.parseInt(val);
			} catch (NumberFormatException e) {
			}
		return def;
	}

	public long getLong(String key, long def)
	{
		String val = getProperty(key);
		if (val != null)
			try {
				return Long.parseLong(val);
			} catch (NumberFormatException e) {
			}
		return def;
	}

	public void setInt(String key, int val)
	{
		setString(key, Integer.toString(val));
	}

	public boolean getBoolean(String key, boolean def)
	{
		String val = getProperty(key);
		if (val != null)
			return Boolean.parseBoolean(val);
		return def;
	}

	public void setBoolean(String key, boolean value)
	{
		setString(key, Boolean.toString(value));
	}

	public synchronized String[] getStringArray(String key)
	{
		int len = getInt(key + ".len", 0);
		String[] ret = new String[len];
		for (int i = 0; i < len; i++)
			ret[i] = getString(key + "." + i, "");
		return ret;
	}

	public synchronized void setStringArray(String key, String[] values)
	{
		int oldLen = getInt(key + ".len", 0);

		setInt(key + ".len", values.length);
		for (int i = 0; i < values.length; i++) {
			setString(key + "." + i, values[i]);
		}
		if (oldLen > values.length) {
			for (int i = values.length; i < oldLen; i++) {
				remove(key + "." + i);
			}
		}
	}

	public synchronized int[] getIntArray(String key)
	{
		int len = getInt(key + ".len", 0);
		int[] ret = new int[len];
		for (int i = 0; i < len; i++)
			ret[i] = getInt(key + "." + i, 0);
		return ret;
	}

	public synchronized void setIntArray(String key, int[] values)
	{
		int oldLen = getInt(key + ".len", 0);

		setInt(key + ".len", values.length);
		for (int i = 0; i < values.length; i++) {
			setInt(key + "." + i, values[i]);
		}
		if (oldLen > values.length) {
			for (int i = values.length; i < oldLen; i++) {
				remove(key + "." + i);
			}
		}
	}

	public synchronized boolean[] getBooleanArray(String key)
	{
		int len = getInt(key + ".len", 0);
		boolean[] ret = new boolean[len];
		for (int i = 0; i < len; i++)
			ret[i] = getBoolean(key + "." + i, false);
		return ret;
	}

	public synchronized void setBooleanArray(String key, boolean[] values)
	{
		int oldLen = getInt(key + ".len", 0);

		setInt(key + ".len", values.length);
		for (int i = 0; i < values.length; i++) {
			setBoolean(key + "." + i, values[i]);
		}
		if (oldLen > values.length) {
			for (int i = values.length; i < oldLen; i++) {
				remove(key + "." + i);
			}
		}
	}
}
