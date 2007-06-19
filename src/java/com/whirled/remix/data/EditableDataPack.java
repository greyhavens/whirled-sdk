//
// $Id$

package com.threerings.msoy.item.remix.data;

import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import java.util.Map;

import java.util.zip.CRC32;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

import com.whirled.DataPack;

/**
 *
 */
public class EditableDataPack extends DataPack
{
    public EditableDataPack ()
    {
    }

    public EditableDataPack (String url, final ResultListener<EditableDataPack> listener)
    {
        super(url, new ResultListener<com.whirled.DataPack>() {
            public void requestCompleted (DataPack pack) {
                // cast to this subclass
                listener.requestCompleted((EditableDataPack) pack);
            }

            public void requestFailed (Exception cause) {
                listener.requestFailed(cause);
            }
        });
    }

    /**
     * Add a new file to this DataPack.
     */
    public void addFile (String filename, String name, FileType type, boolean optional)
        throws IOException
    {
        File file = new File(filename);
        FileInputStream fis = new FileInputStream(file);
        byte[] data = new byte[fis.available()]; // the whole file should be available
        fis.read(data);
        addFile(file.getName(), data, name, type, optional);
    }

    public void addString (String name, String value, boolean optional)
    {
        addData(name, DataType.STRING, StringUtil.encode(value), optional);
    }

    public void addNumber (String name, Double value, boolean optional)
    {
        addData(name, DataType.NUMBER, (value == null) ? null : String.valueOf(value), optional);
    }

    public void addBoolean (String name, Boolean value, boolean optional)
    {
        addData(name, DataType.BOOLEAN, (value == null) ? null : String.valueOf(value), optional);
    }

    public void addArray (String name, String[] array, boolean optional)
    {
        String encoded = null;
        if (array != null) {
            StringBuilder builder = new StringBuilder();
            for (int ii = 0; ii < array.length; ii++) {
                if (ii > 0) {
                    builder.append(",");
                    builder.append(StringUtil.encode(array[ii]));
                }
            }
            encoded = builder.toString();
        }
        addData(name, DataType.ARRAY, encoded, optional);
    }

    public void addPoint (String name, Point2D.Double point, boolean optional)
    {
        String encoded = null;
        if (point != null) {
            encoded = String.valueOf(point.getX()) + "," + String.valueOf(point.getY());
        }
        addData(name, DataType.POINT, encoded, optional);
    }

    public void addRectangle (String name, Rectangle2D.Double rec, boolean optional)
    {
        String encoded = null;
        if (rec != null) {
            encoded = String.valueOf(rec.getX()) + "," + String.valueOf(rec.getY()) + "," +
                String.valueOf(rec.getWidth()) + "," + String.valueOf(rec.getHeight());
        }
        addData(name, DataType.RECTANGLE, encoded, optional);
    }

    /**
     * Add a data parameter.
     */
    protected void addData (String name, DataType type, String value, boolean optional)
    {
        if (!optional && value == null) {
            throw new IllegalArgumentException("Cannot set non-optional value to null.");
        }

        DataEntry entry = new DataEntry();
        entry.name = StringUtil.encode(name);
        entry.type = type;
        entry.value = value;
        entry.optional = optional;

        _metadata.datas.put(name, entry);
    }

    /**
     * Add a new file to this DataPack.
     */
    public void addFile (String filename, byte[] data, String name, FileType type, boolean optional)
    {
        _files.put(filename, data);

        FileEntry entry = new FileEntry();
        entry.name = StringUtil.encode(name);
        entry.type = type;
        entry.value = filename;
        entry.optional = optional;

        _metadata.files.put(name, entry);
    }

    /**
     * Write this datapack out to the specified filename.
     */
    public void writeTo (String filename)
        throws IOException
    {
        FileOutputStream fos = new FileOutputStream(filename);
        writeTo(fos);
        fos.close();
    }

    /**
     * Write the DataPack to the specified stream.
     */
    protected void writeTo (OutputStream out)
        throws IOException
    {
        ZipOutputStream zos = new ZipOutputStream(out);
        zos.setMethod(ZipOutputStream.STORED);
        CRC32 crc = new CRC32();

        // TODO: If we put (an) Adler32 checksum(s) *somewhere* in here, then flash can read
        // entries that are DEFLATED. However, I don't at this time know how or where this
        // checksum is to be injected. If we figure it out in the future we can start compressing
        // the data. Note that this is irrelevant for the common media types: png, gif, jpg, swf,
        // and mp3 are all already compressed and are best simply STORED.

        for (Map.Entry<String,byte[]> file : _files.entrySet()) {
            byte[] data = file.getValue();
            ZipEntry entry = new ZipEntry(file.getKey());
            entry.setSize(data.length);
            crc.reset();
            crc.update(data);
            entry.setCrc(crc.getValue());
            zos.putNextEntry(entry);
            zos.write(data, 0, data.length);
            zos.closeEntry();
        }

        // write the metadata
        byte[] data = _metadata.toXML().getBytes("utf-8");
        ZipEntry entry = new ZipEntry("_data.xml");
        entry.setSize(data.length);
        crc.reset();
        crc.update(data);
        entry.setCrc(crc.getValue());
        zos.putNextEntry(entry);
        zos.write(data, 0, data.length);
        zos.closeEntry();

        zos.finish();
    }

    // for yon testing
    public static void main (String[] args)
    {
        new EditableDataPack("http://tasman.sea.earth.threerings.net:8080/ClockPack.dpk",
            new ResultListener<EditableDataPack>() {
                public void requestCompleted (EditableDataPack pack)
                {
                    try {
                        //pack.addFile("/home/ray/media/mp3/tarzan and jane - Tarzan & Jane.mp3",
                        //    "music", FileType.BLOB, true);
                        pack.writeTo("/export/msoy/pages/ClockPack.jpk");

                    } catch (IOException ioe) {
                        System.err.println("ioe: " + ioe);
                        ioe.printStackTrace();
                    }
                }

                public void requestFailed (Exception cause)
                {
                    System.err.println("Oh noes: " + cause);
                }
            });
    }
}
