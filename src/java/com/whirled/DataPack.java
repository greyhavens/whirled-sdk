package com.whirled;

import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import java.awt.image.BufferedImage;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;

import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import java.util.HashMap;

import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import javax.imageio.ImageIO;

import org.apache.commons.digester.Digester;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

import com.samskivert.xml.SetPropertyFieldsRule;

public class DataPack
{
    public DataPack (final String url, final ResultListener<DataPack> listener)
    {
        Thread tt = new Thread() {
            public void run () {
                try {
                    URL u = new URL(url);
                    HttpURLConnection conn = (HttpURLConnection) u.openConnection();
                    // TODO: This is qualified only to work past a bug in Eclipse. I apologize for
                    // TODO: making our code uglier to cater to an IDE; let's hope it's fixed soon.
                    DataPack.this.init(conn.getInputStream());

                } catch (MalformedURLException mue) {
                    listener.requestFailed(mue);
                    return;

                } catch (IOException ioe) {
                    listener.requestFailed(ioe);
                    return;
                }

                // finally, ensure we ever got _data.xml
                if (_metadata != null) {
                    listener.requestCompleted(DataPack.this);

                } else {
                    listener.requestFailed(new Exception("No _data.xml contained in DataPack."));
                }
            }
        };

        tt.start();
    }

    protected DataPack ()
    {
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
        return !_closed && (_metadata != null);
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
     * Convenience method to access some data as a Rectangle.
     */
    public Rectangle2D.Double getRectangle (String name)
    {
        return (Rectangle2D.Double) getData(name);
    }

    /**
     * Get some data.
     */
    public Object getData (String name)
    {
        name = validateAccess(name);

        DataEntry entry = _metadata.datas.get(name);
        if (entry == null) {
            return null;
        }

        String type = entry.type;
        String value = entry.value;
        if (value == null) {
            return null;
        }
        
        if ("String".equals(type)) {
            return StringUtil.decode(value);

        } else if ("Number".equals(type)) {
            try {
                return new Double(value);

            } catch (NumberFormatException nfe) {
                return Double.valueOf(Double.NaN);
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
                return new Point2D.Double();
            }

        } else if ("Rectangle".equals(type)) {
            String[] bits = value.split(",");
            try {
                return new Rectangle2D.Double(
                    Double.parseDouble(bits[0]), Double.parseDouble(bits[1]),
                    Double.parseDouble(bits[2]), Double.parseDouble(bits[3]));

            } catch (NumberFormatException nfe) {
                return new Rectangle2D.Double();
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
        name = validateAccess(name);

        FileEntry entry = _metadata.files.get(name);
        if (entry == null) {
            return null;
        }

        String type = entry.type;
        String value = entry.value;
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

    protected String validateAccess (String name)
    {
        if (_metadata == null) {
            throw new IllegalStateException("DataPack is not loaded.");
        }
        if (name == null) {
            throw new IllegalArgumentException("Invalid file name: " + name);
        }

        return StringUtil.encode(name);
    }

    /**
     * Parse and initialize the DataPack.
     */
    protected void init (InputStream ins)
        throws IOException
    {
        MetaData metadata = null;

        ZipInputStream zis = new ZipInputStream(ins);
        ZipEntry entry;
        while (!_closed && null != (entry = zis.getNextEntry())) {
            String name = entry.getName();
            byte[] data = new byte[(int) entry.getSize()];

            int offset = 0;
            int read = 0;
            while (!_closed && read != -1 && offset != data.length) {
                read = zis.read(data, offset, data.length - offset);
                offset += read;
            }

            if ("_data.xml".equals(name)) {
                metadata = parseMetaData(data);

            } else {
                _files.put(name, data);
            }
        }

        // only after we've had success parsing everything do we accept the metadata
        _metadata = metadata;
    }

    protected MetaData parseMetaData (byte[] data)
        throws IOException
    {
        Digester digester = new Digester();
        digester.addObjectCreate("datapack", MetaData.class);
        digester.addRule("datapack", new SetPropertyFieldsRule());
        digester.addRule("datapack/data", new SetPropertyFieldsRule() {
            public void begin (String namespace, String name, Attributes attrs)
                throws Exception
            {
                digester.push(new DataEntry());
                super.begin(namespace, name, attrs);
            }

            public void end (String namespace, String name)
                throws Exception
            {
                DataEntry entry = (DataEntry) digester.pop();
                MetaData metadata = (MetaData) digester.peek();
                metadata.datas.put(entry.name, entry);
            }
        });
        digester.addRule("datapack/file", new SetPropertyFieldsRule() {
            public void begin (String namespace, String name, Attributes attrs)
                throws Exception
            {
                digester.push(new FileEntry());
                super.begin(namespace, name, attrs);
            }

            public void end (String namespace, String name)
                throws Exception
            {
                FileEntry entry = (FileEntry) digester.pop();
                MetaData metadata = (MetaData) digester.peek();
                metadata.files.put(entry.name, entry);
            }
        });

        try {
            return (MetaData) digester.parse(new ByteArrayInputStream(data));
        } catch (SAXException saxe) {
            throw (IOException) new IOException().initCause(saxe);
        }
    }

    protected static class AbstractEntry
    {
        /** The name of the data, uuencoded. */
        public String name;

        /** A human description, uuencoded. */
        public String info = "";

        /** The type of the data. */
        public String type;

        /** The value, uuencoded, or null if none. */
        public String value;

        /** Is this value optional? */
        public boolean optional;

        protected void attrsToXML (StringBuilder buf)
        {
            buf.append(" name=\"").append(name).append("\"");
            buf.append(" type=\"").append(type).append("\"");
            if (value != null) {
                buf.append(" value=\"").append(value).append("\"");
            }
            if (!"".equals(info)) {
                buf.append(" info=\"").append(info).append("\"");
            }
            if (optional) {
                buf.append(" optional=\"true\"");
            }
        }
    }
    
    /** MetaData entry describing data. */
    protected static class DataEntry extends AbstractEntry
    {
        public DataEntry ()
        {
        }

        /**
         * Convert this entry to XML.
         */
        public String toXML ()
        {
            StringBuilder buf = new StringBuilder("<data");
            attrsToXML(buf);
            buf.append("/>");
            return buf.toString();
        }
    }

    /** MetaData entry describing a file. */
    protected static class FileEntry extends AbstractEntry
    {
        public FileEntry ()
        {
        }

        /**
         * Convert this entry to XML.
         */
        public String toXML ()
        {
            StringBuilder buf = new StringBuilder("<file");
            attrsToXML(buf);
            buf.append("/>");
            return buf.toString();
        }
    }

    /** MetaData holder class. */
    protected static class MetaData
    {
        /** The namespace of this DataPack. */
        public String namespace;

        public MetaData () { }

        /** Data entries. */
        public HashMap<String, DataEntry> datas = new HashMap<String, DataEntry>();

        /** File entries. */
        public HashMap<String, FileEntry> files = new HashMap<String, FileEntry>();

        /**
         * Convert this metadata to XML.
         */
        public String toXML ()
        {
            StringBuilder buf = new StringBuilder("<datapack");
            attrsToXML(buf);
            buf.append(">\n");
            childrenToXML(buf);
            buf.append("</datapack>");
            buf.append('\n'); // output a nice trailing newline
            return buf.toString();
        }

        protected void attrsToXML (StringBuilder buf)
        {
            buf.append(" namespace=\"").append(namespace).append("\"");
        }

        protected void childrenToXML (StringBuilder buf)
        {
            for (DataEntry entry : datas.values()) {
                buf.append('\t').append(entry.toXML()).append('\n');
            }
            for (FileEntry entry : files.values()) {
                buf.append('\t').append(entry.toXML()).append('\n');
            }
        }
    }

    /** The parsed metadata. */
    protected MetaData _metadata;

    /** Indicates when we've been closed early. */
    protected boolean _closed;

    /** File entries that present in the datapack. */
    protected HashMap<String,byte[]> _files = new HashMap<String,byte[]>();
}
