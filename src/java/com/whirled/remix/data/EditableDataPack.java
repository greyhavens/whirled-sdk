//
// $Id$

package com.whirled.remix.data;

import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import java.util.zip.CRC32;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import com.samskivert.util.ObserverList;
import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

import com.whirled.DataPack;

/**
 *
 */
public class EditableDataPack extends DataPack
{
    /**
     * Create a brand-new datapack.
     */
    public EditableDataPack ()
    {
        _metadata = new MetaData();
        unpack();
    }

    /**
     * Load the DataPack at the specified url for remixing.
     */
    public EditableDataPack (String url, final ResultListener<EditableDataPack> listener)
    {
        super(url, new ResultListener<com.whirled.DataPack>() {
            public void requestCompleted (DataPack pack) {
                // cast to this subclass
                EditableDataPack edp = (EditableDataPack) pack;

                edp.unpack();
                listener.requestCompleted(edp);
            }

            public void requestFailed (Exception cause) {
                listener.requestFailed(cause);
            }
        });
    }

    /**
     * Add the specified change listener.
     */
    public void addChangeListener (ChangeListener listener)
    {
        _listeners.add(listener);
    }

    /**
     * Remove the specified change listener.
     */
    public void removeChangeListener (ChangeListener listener)
    {
        _listeners.remove(listener);
    }

    /**
     * Get a list of all the data fields.
     */
    public List<String> getDataFields ()
    {
        validateComplete();

        ArrayList<String> keys = new ArrayList<String>(_metadata.datas.keySet());
        for (int ii = 0, nn = keys.size(); ii < nn; ii++) {
            keys.set(ii, StringUtil.decode(keys.get(ii)));
        }
        return keys;
    }

    /**
     * Get a list of all the file fields.
     */
    public List<String> getFileFields ()
    {
        validateComplete();

        ArrayList<String> keys = new ArrayList<String>(_metadata.files.keySet());
        for (int ii = 0, nn = keys.size(); ii < nn; ii++) {
            keys.set(ii, StringUtil.decode(keys.get(ii)));
        }
        return keys;
    }

    /**
     * Get the DataEntry for the specified name, for direct editing. Don't fuck up!
     */
    public DataEntry getDataEntry (String name)
    {
        name = validateAccess(name);
        return _metadata.datas.get(name);
    }

    public FileEntry getFileEntry (String name)
    {
        name = validateAccess(name);
        return _metadata.files.get(name);
    }

    public void removeDataEntry (String name)
    {
        name = validateAccess(name);
        if (null != _metadata.datas.remove(name)) {
            fireChanged();
        }
    }

    public void removeFileEntry (String name)
    {
        name = validateAccess(name);
        if (null != _metadata.files.remove(name)) {
            fireChanged();
        }
    }

    /**
     * Replace the specified file with a file that's already in the temp dir.
     * Note that the entry value is not updated.
     */
    public String replaceFile (String name, String tempDirFilename)
        throws IOException
    {
        return replaceFile(name, new File(_tempDir, tempDirFilename));
    }

    /**
     * Replace the specified file, returning the temp-dir filename.
     * Note that the entry value is not updated.
     */
    public String replaceFile (String name, File newFile)
        throws IOException
    {
        name = validateAccess(name);
        FileEntry entry = _metadata.files.get(name);
        if (entry == null) {
            throw new IllegalArgumentException("No file named " + name);
        }

        // see if the specified file needs to be moved to the temporary directory
        byte[] data = readFile(newFile);
        String filename;
        if (_tempDir.equals(newFile.getParentFile())) {
            filename = newFile.getPath();

        } else {
            // copy the data into the temp directory
            filename = createTempFile(newFile, data);
        }

        // remember the new data
        _files.put(filename, data);
        return filename;
    }

    protected String createTempFile (File newFile, byte[] data)
        throws IOException
    {
        String name = newFile.getName();
        File outFile = new File(_tempDir, name);

        if (outFile.exists()) {
            // see if the existing file contains the same data
            byte[] otherData = readFile(outFile);
            if (Arrays.equals(data, otherData)) {
                // this file already exists and contains the same data
                return outFile.getName();
            }

            // otherwise, try inserting a number before the extension
            int dot = name.lastIndexOf('.');
            String extension = "";
            if (dot != -1) {
                extension = name.substring(dot);
                name = name.substring(0, dot);
            }
            for (int ii = 2; true; ii++) {
                outFile = new File(_tempDir, name + "_" + ii + extension);
                if (!outFile.exists()) {
                    break;
                }
            }
        }

        // copy the file and return the new name
        name = outFile.getName();
        unpackFile(name, data);
        return name;
    }

    protected byte[] readFile (File file)
        throws IOException
    {
        FileInputStream fis = new FileInputStream(file);
        byte[] data = new byte[fis.available()]; // the whole file should be available
        fis.read(data);
        fis.close();
        return data;
    }

    /**
     * Add a new file to this DataPack.
     */
    public void addFile (String filename, String name, FileType type, String desc, boolean optional)
        throws IOException
    {
        File file = new File(filename);
        byte[] data = readFile(file);
        addFile(file.getName(), data, name, type, desc, optional);
    }

    public void addString (String name, String value, boolean optional)
    {
        addData(name, DataType.STRING, StringUtil.encode(value), null, optional);
    }

    public void addNumber (String name, Double value, boolean optional)
    {
        addData(name, DataType.NUMBER, (value == null) ? null : String.valueOf(value), null,
            optional);
    }

    public void addBoolean (String name, Boolean value, boolean optional)
    {
        addData(name, DataType.BOOLEAN, (value == null) ? null : String.valueOf(value), null,
            optional);
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
        addData(name, DataType.ARRAY, encoded, null, optional);
    }

    public void addPoint (String name, Point2D.Double point, boolean optional)
    {
        String encoded = null;
        if (point != null) {
            encoded = String.valueOf(point.getX()) + "," + String.valueOf(point.getY());
        }
        addData(name, DataType.POINT, encoded, null, optional);
    }

    public void addRectangle (String name, Rectangle2D.Double rec, boolean optional)
    {
        String encoded = null;
        if (rec != null) {
            encoded = String.valueOf(rec.getX()) + "," + String.valueOf(rec.getY()) + "," +
                String.valueOf(rec.getWidth()) + "," + String.valueOf(rec.getHeight());
        }
        addData(name, DataType.RECTANGLE, encoded, null, optional);
    }

    /**
     * Add a data parameter.
     */
    public void addData (String name, DataType type, String value, String desc, boolean optional)
    {
        if (!optional && value == null) {
            throw new IllegalArgumentException("Cannot set non-optional value to null.");
        }

        DataEntry entry = new DataEntry();
        entry.name = StringUtil.encode(name);
        entry.type = type;
        entry.value = value;
        entry.info = StringUtil.encode(desc);
        entry.optional = optional;

        _metadata.datas.put(name, entry);
        fireChanged();
    }

    /**
     * Add a new file to this DataPack.
     */
    public void addFile (
        String filename, byte[] data, String name, FileType type, String desc, boolean optional)
    {
        _files.put(filename, data);

        FileEntry entry = new FileEntry();
        entry.name = StringUtil.encode(name);
        entry.type = type;
        entry.value = filename;
        entry.info = StringUtil.encode(desc);
        entry.optional = optional;

        _metadata.files.put(name, entry);
        fireChanged();
    }

    /**
     * Unpack the files contained in this datapack into the temporary directory.
     */
    protected void unpack ()
    {
        try {
            // create a temporary directory
            _tempDir = File.createTempFile("datapack", ".tmp");
            boolean result = _tempDir.delete();
            if (result) {
                result = _tempDir.mkdir();
                _tempDir.deleteOnExit();
            }
            if (!result) { // if either result fails..
                throw new IOException("Failure creating temporary directory.");
            }

            // now, unpack any files
            for (Map.Entry<String,byte[]> entry : _files.entrySet()) {
                unpackFile(entry.getKey(), entry.getValue());
            }

        } catch (IOException ioe) {
            ioe.printStackTrace();
            _closed = true;
        }
    }

    /**
     * Write the specified file data to the temporary directory.
     */
    protected void unpackFile (String filename, byte[] data)
        throws IOException
    {
        File outFile = new File(_tempDir, filename);
        outFile.deleteOnExit();
        FileOutputStream fos = new FileOutputStream(outFile);
        try {
            fos.write(data);
        } finally {
            fos.close();
        }
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

        // make a list of the filenames to actually save
        HashSet<String> filenames = new HashSet<String>();
        for (FileEntry entry : _metadata.files.values()) {
            if (!StringUtil.isBlank(entry.value)) {
                filenames.add(entry.value);
            }
        }
        // save those files into the zip
        for (String filename : filenames) {
            byte[] data = _files.get(filename);
            System.out.println("Storing '" + filename + "' (" + data.length + " bytes)");
            ZipEntry entry = new ZipEntry(filename);
            entry.setSize(data.length);
            crc.reset();
            crc.update(data);
            entry.setCrc(crc.getValue());
            zos.putNextEntry(entry);
            zos.write(data, 0, data.length);
            zos.closeEntry();
        }

        // write the metadata
        String metaXML = _metadata.toXML();
        byte[] data = metaXML.getBytes("utf-8");
        System.out.println("Storing '_data.xml' (" + data.length + " bytes):");
        System.out.println(metaXML);
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

    /**
     * Fire a ChangeEvent to all our listeners.
     */
    protected void fireChanged ()
    {
        final ChangeEvent event = new ChangeEvent(this);

        _listeners.apply(new ObserverList.ObserverOp<ChangeListener>() {
            public boolean apply (ChangeListener listener) {
                listener.stateChanged(event);
                return true;
            }
        });
    }

    /** Hold change listeners. */
    protected ObserverList<ChangeListener> _listeners =
        new ObserverList<ChangeListener>(ObserverList.FAST_UNSAFE_NOTIFY);

    /** The temporary file directory. */
    protected File _tempDir;

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
