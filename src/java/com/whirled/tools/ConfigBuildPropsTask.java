//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.tools;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import com.samskivert.util.RunAnywhere;

/**
 * Sets up the build.properties file for an SDK installation interactively.
 */
public class ConfigBuildPropsTask extends Task
{
    /**
     * Points us to the build.properties file that we'll be creating.
     */
    public void setProps (File props)
    {
        _props = props;
    }

    @Override // documentation inherited
    public void execute () throws BuildException
    {
        Properties props = new Properties();
        if (_props.exists()) {
            try {
                props.load(new FileInputStream(_props));
            } catch (IOException ioe) {
                System.err.println("Failure reading " + _props + ": " + ioe);
            }
        }

        // if we've already got the goods, we're good to go
        File sdkpath = new File(props.getProperty("flex.path", ""));
        File playerpath = new File(props.getProperty("player.path", ""));
        if (isValidSDKPath(sdkpath) && isValidPlayerPath(playerpath)) {
            return;
        }

        // otherwise pop up dialogs asking where things are
        sdkpath = displayPickSDK(sdkpath.getParentFile());
        if (RunAnywhere.isMacOS()) {
            // on the Mac we just run "open foo.swf"
            playerpath = new File("/usr/bin/open");
        } else {
            playerpath = displayPickPlayer(sdkpath.getParentFile());
        }

        // and create the new build.properties file
        props.setProperty("flex.path", sdkpath.getAbsolutePath());
        props.setProperty("player.path", playerpath.getAbsolutePath());
        try {
            props.store(new FileOutputStream(_props), "Auto-generated build properties");
        } catch (IOException ioe) {
            throw new BuildException("Failed to write " + _props + ": " + ioe);
        }

        // set the properties in the current project so that they're around for the build
        getProject().setNewProperty("flex.path", sdkpath.getAbsolutePath());
        getProject().setNewProperty("player.path", playerpath.getAbsolutePath());
    }

    protected boolean isValidSDKPath (File path)
    {
        String optimizer = path.getPath() + File.separator + "bin" + File.separator +
            "optimizer.exe";
        return new File(optimizer).exists();
    }

    protected boolean isValidPlayerPath (File path)
    {
        return path.exists();
    }

    protected File displayPickSDK (File curdir) throws BuildException
    {
        JOptionPane.showMessageDialog(
            null, SELECT_SDK_MSG, SELECT_SDK_TITLE, JOptionPane.INFORMATION_MESSAGE);
        String errmsg = "Please see " + FALLBACK_URL + " for info on downloading the Flex SDK.";
        do {
            JFileChooser chooser = new JFileChooser(curdir);
            chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
            chooser.setDialogTitle("Where is your Flex SDK?");
            int returnVal = chooser.showDialog(null, "Select");
            if (returnVal != JFileChooser.APPROVE_OPTION) {
                throw new BuildException(errmsg);
            }

            File sdkdir = chooser.getSelectedFile();
            if (isValidSDKPath(sdkdir)) {
                return sdkdir;
            }

            String[] options = { "Pick Again", "Cancel" };
            int choice = JOptionPane.showOptionDialog(
                null, INVALID_SDK_MSG, INVALID_SDK_TITLE, JOptionPane.DEFAULT_OPTION,
                JOptionPane.ERROR_MESSAGE, null, options, options[0]);
            if (choice != 0) {
                throw new BuildException(errmsg);
            }

        } while (true);
    }

    protected File displayPickPlayer (File curdir) throws BuildException
    {
        JOptionPane.showMessageDialog(
            null, SELECT_PLAYER_MSG, SELECT_PLAYER_TITLE, JOptionPane.INFORMATION_MESSAGE);
        JFileChooser chooser = new JFileChooser(curdir);
        chooser.setDialogTitle("Where is your standalone Flash player?");
        int returnVal = chooser.showDialog(null, "Select");
        if (returnVal != JFileChooser.APPROVE_OPTION) {
            throw new BuildException("Please see " + FALLBACK_URL +
                                     " for info on downloading the standalone Flash player.");
        }
        return chooser.getSelectedFile();
    }

    protected File _props;

    protected static final String FALLBACK_URL =
        "http://wiki.whirled.com/Setting_up_your_programming_environment";

    protected static final String SELECT_SDK_TITLE = "Specify Flex 3 SDK Path";
    protected static final String SELECT_SDK_MSG =
        "We need to know the location of your Flex 3 SDK.\n\n" +
        "If you are following the instructions from the Wiki, you have\n" +
        "probably installed this in a directory named: flex_sdk_3\n\n" +
        "Please click 'OK' and then a file dialog will appear in which\n" +
        "you can select the appropriate directory.";

    protected static final String INVALID_SDK_TITLE = "Invalid Flex 3 SDK Path";
    protected static final String INVALID_SDK_MSG =
        "The path you specified to the Flex SDK does not appear to contain a Flex 3 SDK.\n" +
        "Please choose the directory in which you unpacked the flex_sdk_3.zip file.\n" +
        "It should contain subdirectories like lib, bin, asdoc, etc.\n\n" +
        "For instructions on how and where to download the Flex 3 SDK please \n" +
        "go to " + FALLBACK_URL;

    protected static final String SELECT_PLAYER_TITLE = "Specify Standalone Flash Player Path";
    protected static final String SELECT_PLAYER_MSG =
        "We need to know the location of your Standalone Flash Player.\n\n" +
        "On Windows it is usually named: sa_flashplayer_9_debug.exe\n" +
        "On Linux it is usually named: flashplayer\n\n" +
        "Please click 'OK' and then a file dialog will appear in which\n" +
        "you can select the appropriate executable.";
}
