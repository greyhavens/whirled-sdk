package com.whirled;

import java.awt.geom.Point2D;

import java.awt.image.BufferedImage;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;

import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import java.util.HashMap;

import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipInputStream;

import javax.imageio.ImageIO;

import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

public class DataPack
{
    public DataPack (final String url, final ResultListener<DataPack> listener)
    {
        Thread tt = new Thread() {
            public void run () {
                try {
                    URL u = new URL(url);
                    HttpURLConnection conn = (HttpURLConnection) u.openConnection();

                    ZipInputStream zis = new ZipInputStream(conn.getInputStream());
                    ZipEntry entry;
                    while (!_closed && null != (entry = zis.getNextEntry())) {
                        String name = entry.getName();
                        System.err.println("Found entry '" + name + "' at " + entry.getSize() + 
                            "bytes");
                        byte[] data = new byte[(int) entry.getSize()];

                        int offset = 0;
                        int read = 0;
                        while (!_closed && read != -1 && offset != data.length) {
                            read = zis.read(data, offset, data.length - offset);
                            offset += read;
                        }

                        if ("_data.xml".equals(name)) {
                            // TODO: parse the XML
                            _data = new String(data, "utf-8");

                        } else {
                            _files.put(name, data);
                        }
                    }

                } catch (MalformedURLException mue) {
                    listener.requestFailed(mue);
                    return;

                } catch (IOException ioe) {
                    listener.requestFailed(ioe);
                    return;
                }

                listener.requestCompleted(DataPack.this);
            }
        };

        tt.start();
    }

    /**
     * Stop loading a DataPack, if not yet complete. Call this if you need to shutdown.
     */
    public void close ()
    {
        _closed = true;
    }

    /**
     * Has the loading of the datapack completed?
     */
    public boolean isComplete ()
    {
        // TODO: Verify
        return !_closed && (_data != null);
    }

    /**
     * Convenience method to access some data as a String.
     */
    public String getString (String name)
    {
        return (String) getData(name);
    }

    /**
     * Convenience method to access some data as a Number (Double).
     */
    public Double getNumber (String name)
    {
        return (Double) getData(name);
    }

    /**
     * Convenience method to access some data as a Boolean.
     */
    public Boolean getBoolean (String name)
    {
        return (Boolean) getData(name);
    }

    /**
     * Convenience method to access some data as an array.
     */
    public String[] getArray (String name)
    {
        return (String[]) getData(name);
    }

    /**
     * Convenience method to access some data as a Point.
     */
    public Point2D.Double getPoint (String name)
    {
        return (Point2D.Double) getData(name);
    }

    /**
     * Get some data.
     */
    public Object getData (String name)
    {
        validateAccess(name);

        // TODO: locate the right entry in the XML, find the value, etc.

        String type = "TODO";
        String value = null;
        if (value == null) {
            return null;
        }
        
        if ("String".equals(type)) {
            return StringUtil.decode(value);

        } else if ("Number".equals(type)) {
            try {
                return new Double(value);

            } catch (NumberFormatException nfe) {
                // TODO: what? I freak out?
            }

        } else if ("Boolean".equals(type)) {
            return Boolean.valueOf("true".equals(value.toLowerCase()));

        } else if ("Array".equals(type)) {
            // StringUtil.parseStringArray doesn't do things the way we'd like...
            String[] array = value.split(",");
            for (int ii = 0; ii < array.length; ii++) {
                array[ii] = StringUtil.decode(array[ii]);
            }
            return array;

        } else if ("Point".equals(type)) {
            String[] bits = value.split(",");
            try {
                return new Point2D.Double(Double.parseDouble(bits[0]), Double.parseDouble(bits[1]));

            } catch (NumberFormatException nfe) {
                // TODO: what? I freak out?
            }
        }

        System.err.println("Unknown resource type: " + type);
        return value;
    }

    /**
     * Get a File as a byte[].
     */
    public byte[] getFile (String name)
    {
        return (byte[]) getFile(name, false);
    }

    /**
     * Get a File as a String.
     */
    public String getFileAsString (String name)
    {
        return (String) getFile(name, true);
    }

    /**
     * Convenience method to get a File as an Image.
     */
    public BufferedImage getImage (String name)
    {
        byte[] data = getFile(name);
        if (data == null) {
            return null;
        }
        try {
            return ImageIO.read(new ByteArrayInputStream(data));

        } catch (IOException ioe) {
            System.err.println("Not possible: " + ioe);
            return null;
        }
    }

    protected Object getFile (String name, boolean asString)
    {
        validateAccess(name);

        // TODO: locate the entry in XML, etc.

        String value = null;
        if (value == null) {
            return null;
        }

        byte[] data = _files.get(value);
        if (data != null && asString) {
            try {
                return new String(data, "utf-8");

            } catch (UnsupportedEncodingException uee) {
                // what? No utf-8?
                return new String(data);
            }
        }
        return data;
    }

    protected void validateAccess (String name)
    {
        if (name == null) {
            throw new IllegalArgumentException("Invalid file name: " + name);
        }
        if (_data == null) {
            throw new IllegalStateException("DataPack is not loaded.");
        }
    }

    protected boolean _closed;

    protected String _data;

    protected HashMap<String,byte[]> _files = new HashMap<String,byte[]>();
}
