//
// $Id$

package com.whirled.tools;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import java.util.ArrayList;
import java.util.Map;
import java.util.Properties;

import com.samskivert.io.StreamUtil;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DirectoryScanner;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.FileSet;

/**
 * Generates ID assignments for a list of files.
 */
public class AssignIdTask extends Task
{
    /**
     * Adds a nested fileset element which enumerates to be enumerated files.
     */
    public void addFileset (FileSet set)
    {
        _filesets.add(set);
    }

    /**
     * Specifies the name of the properties file.
     */
    public void setPropfile (File propfile)
    {
        _propfile = propfile;
    }

    /**
     * Performs the actual work of the task.
     */
    public void execute () throws BuildException
    {
        if (_propfile == null) {
            throw new BuildException("Missing 'propfile' parameter.");
        }

        Properties props = new Properties();
        FileInputStream fin = null;
        try {
            if (_propfile.exists()) {
                props.load(fin = new FileInputStream(_propfile));
            }
        } catch (IOException ioe) {
            throw new BuildException("Failed loading " + _propfile + ".", ioe);
        } finally {
            StreamUtil.close(fin);
        }

        int maxValue = 0;
        for (Map.Entry<Object,Object> entry : props.entrySet()) {
            Integer value = Integer.parseInt((String)entry.getValue());
            maxValue = Math.max(maxValue, value);
        }

        boolean modified = false;
        for (FileSet fs : _filesets) {
            DirectoryScanner ds = fs.getDirectoryScanner(getProject());
            for (String file : ds.getIncludedFiles()) {
                if (!props.containsKey(file)) {
                    props.setProperty(file, String.valueOf(++maxValue));
                    modified = true;
                }
            }
        }

        if (modified) {
            FileOutputStream fout = null;
            try {
                props.store(fout = new FileOutputStream(_propfile), "");
            } catch (IOException ioe) {
                throw new BuildException("Failed saving " + _propfile + ".", ioe);
            } finally {
                StreamUtil.close(fout);
            }
        }
    }

    /** The filesets that contain our to be enumerated files. */
    protected ArrayList<FileSet> _filesets = new ArrayList<FileSet>();

    /** The properties file that will contain our enumerated ids. */
    protected File _propfile;
}
