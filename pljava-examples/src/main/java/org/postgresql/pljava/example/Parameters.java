/*
 * Copyright (c) 2004-2013 Tada AB and other contributors, as listed below.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the The BSD 3-Clause License
 * which accompanies this distribution, and is available at
 * http://opensource.org/licenses/BSD-3-Clause
 *
 * Contributors:
 *   Tada AB
 */
package org.postgresql.pljava.example;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.logging.Logger;

/**
 * Some methods used for testing parameter and return value coersion and
 * resolution of overloaded methods.
 * 
 * @author Thomas Hallgren
 */
public class Parameters {
	public static double addNumbers(short a, int b, long c, BigDecimal d,
			BigDecimal e, float f, double g) {
		return d.doubleValue() + e.doubleValue() + a + b + c + f + g;
	}

	public static int addOne(int value) {
		return value + 1;
	}

	public static int addOne(Integer value) {
		return value.intValue() + 1;
	}

	public static int addOneLong(long value) {
		return (int) value + 1;
	}

	public static int countNulls(Integer[] intArray) throws SQLException {
		int nullCount = 0;
		int top = intArray.length;
		for (int idx = 0; idx < top; ++idx) {
			if (intArray[idx] == null)
				nullCount++;
		}
		return nullCount;
	}

	public static int countNulls(ResultSet input) throws SQLException {
		int nullCount = 0;
		int top = input.getMetaData().getColumnCount();
		for (int idx = 1; idx <= top; ++idx) {
			input.getObject(idx);
			if (input.wasNull())
				nullCount++;
		}
		return nullCount;
	}

	public static Date getDate() {
		return new Date(System.currentTimeMillis());
	}

	public static Time getTime() {
		return new Time(System.currentTimeMillis());
	}

	public static Timestamp getTimestamp() {
		return new Timestamp(System.currentTimeMillis());
	}

	static void log(String msg) {
		// GCJ has a somewhat serious bug (reported)
		//
		if ("GNU libgcj".equals(System.getProperty("java.vm.name"))) {
			System.out.print("INFO: ");
			System.out.println(msg);
		} else
			Logger.getAnonymousLogger().config(msg);
	}

	public static Integer nullOnEven(int value) {
		return (value % 2) == 0 ? null : new Integer(value);
	}

	public static byte print(byte value) {
		log("byte " + value);
		return value;
	}

	public static byte[] print(byte[] byteArray) {
		StringBuffer buf = new StringBuffer();
		int top = byteArray.length;
		buf.append("byte[] of size " + top);
		if (top > 0) {
			buf.append(" {");
			buf.append(byteArray[0]);
			for (int idx = 1; idx < top; ++idx) {
				buf.append(',');
				buf.append(byteArray[idx]);
			}
			buf.append('}');
		}
		log(buf.toString());
		return byteArray;
	}

	public static String print(String value)
	{
		log("string " + value);
		return value;
	}

	public static String print(Date time) {
		TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
		DateFormat p = DateFormat.getDateInstance(DateFormat.FULL);
		log("Local Date is " + p.format(time));
		log("TZ =  " + TimeZone.getDefault().getDisplayName());
		return p.format(time);
	}

	public static double print(double value) {
		log("double " + value);
		return value;
	}

	public static double[] print(double[] doubleArray) {
		StringBuffer buf = new StringBuffer();
		int top = doubleArray.length;
		buf.append("double[] of size " + top);
		if (top > 0) {
			buf.append(" {");
			buf.append(doubleArray[0]);
			for (int idx = 1; idx < top; ++idx) {
				buf.append(',');
				buf.append(doubleArray[idx]);
			}
			buf.append('}');
		}
		log(buf.toString());
		return doubleArray;
	}

	public static float print(float value) {
		log("float " + value);
		return value;
	}

	public static float[] print(float[] floatArray) {
		StringBuffer buf = new StringBuffer();
		int top = floatArray.length;
		buf.append("float[] of size " + top);
		if (top > 0) {
			buf.append(" {");
			buf.append(floatArray[0]);
			for (int idx = 1; idx < top; ++idx) {
				buf.append(',');
				buf.append(floatArray[idx]);
			}
			buf.append('}');
		}
		log(buf.toString());
		return floatArray;
	}

	public static int print(int value) {
		log("int " + value);
		return value;
	}

	public static int[] print(int[] intArray) {
		StringBuffer buf = new StringBuffer();
		int top = intArray.length;
		buf.append("int[] of size " + top);
		if (top > 0) {
			buf.append(" {");
			buf.append(intArray[0]);
			for (int idx = 1; idx < top; ++idx) {
				buf.append(',');
				buf.append(intArray[idx]);
			}
			buf.append('}');
		}
		log(buf.toString());
		return intArray;
	}

	public static Integer[] print(Integer[] intArray) {
		StringBuffer buf = new StringBuffer();
		int top = intArray.length;
		buf.append("Integer[] of size " + top);
		if (top > 0) {
			buf.append(" {");
			buf.append(intArray[0]);
			for (int idx = 1; idx < top; ++idx) {
				buf.append(',');
				buf.append(intArray[idx]);
			}
			buf.append('}');
		}
		log(buf.toString());
		return intArray;
	}

	public static long print(long value) {
		log("long " + value);
		return value;
	}

	public static long[] print(long[] longArray) {
		StringBuffer buf = new StringBuffer();
		int top = longArray.length;
		buf.append("long[] of size " + top);
		if (top > 0) {
			buf.append(" {");
			buf.append(longArray[0]);
			for (int idx = 1; idx < top; ++idx) {
				buf.append(',');
				buf.append(longArray[idx]);
			}
			buf.append('}');
		}
		log(buf.toString());
		return longArray;
	}

	public static short print(short value) {
		log("short " + value);
		return value;
	}

	public static short[] print(short[] shortArray) {
		StringBuffer buf = new StringBuffer();
		int top = shortArray.length;
		buf.append("short[] of size " + top);
		if (top > 0) {
			buf.append(" {");
			buf.append(shortArray[0]);
			for (int idx = 1; idx < top; ++idx) {
				buf.append(',');
				buf.append(shortArray[idx]);
			}
			buf.append('}');
		}
		log(buf.toString());
		return shortArray;
	}

	public static String print(Time time) {
		TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
		DateFormat p = new SimpleDateFormat("HH:mm:ss z Z");
		log("Local Time is " + p.format(time));
		log("TZ =  " + TimeZone.getDefault().getDisplayName());
		return p.format(time);
	}

	public static String print(Timestamp time) {
		TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
		DateFormat p = DateFormat.getDateTimeInstance(DateFormat.FULL,
				DateFormat.FULL);
		log("Local Timestamp is " + p.format(time));
		log("TZ =  " + TimeZone.getDefault().getDisplayName());
		return p.format(time);
	}
}
