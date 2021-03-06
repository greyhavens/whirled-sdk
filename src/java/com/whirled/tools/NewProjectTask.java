//
// $Id$
//
// Copyright (c) 2007-2011 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.tools;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileWriter;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;

import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

/**
 * An ant task that generates a new game project from a template file and some user input.
 */
public class NewProjectTask extends Task
{
    /**
     * Tells the task where to find its template files.
     */
    public void setTemplates (File templates)
    {
        _templates = templates;
    }

    /**
     * Sets the type of thing we're making.
     */
    public void setType (String type)
    {
        _type = type;
    }

    /**
     * Sets the url to display for server agent information.
     */
    public void setServerAgentInfoUrl (String url)
    {
        _serverAgentInfoUrl = url;
    }

    @Override // documentation inherited
    public void execute () throws BuildException
    {
        // first we need to ask the user for some information
        BufferedReader input = new BufferedReader(new InputStreamReader(System.in));

        // if our type was not set, ask the user what type to create
        if (_type == null) {
            System.out.println("What type of project would you like to create?");
            for (Map.Entry<String,String> entry : _choiceMap.entrySet()) {
                System.out.println(entry.getKey() + " - " + entry.getValue());
            }
            do {
                _type = _choiceMap.get(readInput(input, "Enter the number [1-7]?"));
            } while (_type == null);
        }

        Boolean makeServerAgent = false;
        if (GAME_TYPE.equals(_type) && _serverAgentInfoUrl != null) {
            System.out.println("Whirled games can optionally employ a server agent. This is");
            System.out.println("recommended for multi-player games, but is more complicated to ");
            System.out.println("write. For more information, see:");
            System.out.println();
            System.out.println("   " + _serverAgentInfoUrl);
            System.out.println();
            System.out.println("Do you want your game to employ a server agent?");

            do {
                String answer = readInput(input, "Enter [y/n]:");
                makeServerAgent = _boolMap.get(answer.toLowerCase());
            } while (makeServerAgent == null);

        } else if (AVRG_TYPE.equals(_type)) {
            makeServerAgent = true;
        }

        String project;
        do {
            System.out.println("Please enter the name of your " + _type + " project.");
            project = readInput(input, "For example, Best" + _type + "Ever:");

            System.out.println("Your main class will be called:");
            System.out.println("  " + project + ".as");

        } while (!readConfirm(input));

        // create a directory for the project
        File pdir = new File(project.toLowerCase());
        makeDir(pdir);

        // customize the template files and copy them into the right place
        HashMap<String, String> subs = new HashMap<String, String>();
        subs.put("project", project);
        subs.put("type", _type.toLowerCase());
        subs.put("serveragentpropprefix", makeServerAgent ? "" : "<!--");
        subs.put("serveragentpropsuffix", makeServerAgent ? "" : "-->");

        copyFile(input, new File(_templates, "build.xml"), new File(pdir, "build.xml"), subs);
        copyFile(input, new File(_templates, "build.bat"), new File(pdir, "build.bat"), subs);
        copyFile(input, new File(_templates, _type + ".as"), new File(pdir, project + ".as"), subs);

        if (makeServerAgent) {
            String tmpl = AVRG_TYPE.equals(_type) ? "AVRGServer.as" : "Server.as";
            copyFile(input, new File(_templates, tmpl), new File(pdir, "Server.as"), subs);
        }

        System.out.println("Done! Your new project has been created in '" + pdir + "'.");
    }

    protected String readInput (BufferedReader input, String prompt)
        throws BuildException
    {
        String line;
        try {
            do {
                System.out.print(prompt);
                line = input.readLine();
                if (line == null) { // handle EOF
                    throw new BuildException("Aborting");
                }

            } while (line.length() == 0);
            return line;

        } catch (IOException ioe) {
            throw new BuildException("Error reading input: " + ioe);
        }
    }

    protected boolean readConfirm (BufferedReader input)
        throws BuildException
    {
        return readInput(input, "Is this OK? [y/n]").equalsIgnoreCase("y");
    }

    protected void makeDir (File dir)
        throws BuildException
    {
        if (!(dir.exists() && dir.isDirectory())) {
            if (!dir.mkdirs()) {
                throw new BuildException("Failed to create directory '" + dir + "'.");
            }
        }
    }

    protected void copyFile (
        BufferedReader input, File source, File dest,
        HashMap<String, String> subs)
    {
        // ask whether to overwrite if the file already exists
        if (dest.exists()) {
            if (!_overwriteAll) {
                String response = readInput(
                    input, "File '" + dest + "' already exists. Overwrite? [y/n/A]");
                if (response.equalsIgnoreCase("y")) {
                    // fall through and overwrite
                } else if (response.equals("A")) {
                    _overwriteAll = true;
                    // fall through and overwrite
                } else {
                    System.out.println("Leaving '" + dest + "' as is.");
                    return;
                }
            }
            System.out.println("  Overwriting '" + dest + "'.");
        } else {
            System.out.println("  Creating '" + dest + "'.");
        }

        try {
            BufferedReader in = new BufferedReader(new FileReader(source));
            FileWriter out = new FileWriter(dest);
            String line;
            StringBuffer sline = new StringBuffer();
            while ((line = in.readLine()) != null) {
                Matcher m = _subre.matcher(line);
                while (m.find()) {
                    // convert single backslashes to double backslashes,
                    // otherwise appendReplacement will interpret them as escape sequences.
                    String replacement = subs.get(m.group(1)).replaceAll("\\\\", "\\\\\\\\");
                    m.appendReplacement(sline, replacement);
                }
                m.appendTail(sline);
                out.write(sline.toString());
                sline.setLength(0);
                out.write(LINE_SEP);
            }
            out.close();
            in.close();

        } catch (IOException ioe) {
            throw new BuildException("Failed to create '" + dest + "': " + ioe);
        }
    }

    protected String _type;
    protected File _templates;
    protected boolean _overwriteAll;
    protected Pattern _subre = Pattern.compile("@([A-Za-z0-9]+)@");
    protected String _serverAgentInfoUrl;

    protected static final String AVRG_TYPE = "AVRG";
    protected static final String GAME_TYPE = "Game";

    protected static TreeMap<String,String> _choiceMap = new TreeMap<String,String>();
    static {
        _choiceMap.put("1", "Avatar");
        _choiceMap.put("2", GAME_TYPE);
        _choiceMap.put("3", "Pet");
        _choiceMap.put("4", "Furni");
        _choiceMap.put("5", "Toy");
        _choiceMap.put("6", "Backdrop");
        _choiceMap.put("7", AVRG_TYPE);
    }

    protected static TreeMap<String,Boolean> _boolMap = new TreeMap<String,Boolean>();
    static {
        _boolMap.put("y", true);
        _boolMap.put("n", false);
    }
    protected static final String LINE_SEP = System.getProperty("line.separator");
}
