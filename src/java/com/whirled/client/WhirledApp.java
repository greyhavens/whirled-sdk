//
// $Id$

package com.whirled.client;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import com.samskivert.swing.util.SwingUtil;
import com.samskivert.util.LoggingLogProvider;
import com.samskivert.util.OneLineLogFormatter;

import com.threerings.media.FrameManager;
import com.threerings.media.ManagedJFrame;
import com.threerings.util.Name;

import com.whirled.server.LocalServer;

/**
 * The main entry point for the Whirled standalone test client.
 */
public class WhirledApp
{
    public void init (String username, String gameId)
        throws Exception
    {
        // create a frame and our frame manager
        _frame = new ManagedJFrame(username);
        _frame.setDefaultCloseOperation(ManagedJFrame.EXIT_ON_CLOSE);
        _framemgr = FrameManager.newInstance(_frame);

        // TODO: remember the position of the frame based on username
        _frame.setSize(800, 600);
        SwingUtil.centerWindow(_frame);

        // create and initialize our client instance
        _client = new WhirledClient();
        _client.init(_frame, gameId);
    }

    public void run (String username)
    {
        // show the frame
        _frame.setVisible(true);

        // log on to our local server
        _server.startStandaloneClient(_client, new Name(username));

        // start up the frame manager
        _framemgr.start();
    }

    public static void main (String[] args)
        throws Exception
    {
        com.samskivert.util.Log.setLogProvider(new LoggingLogProvider());
        OneLineLogFormatter.configureDefaultHandler();

        // start up our local server
        _server = new LocalServer();
        _server.init();

        String gameId = (args.length > 0) ? args[0] : "unknown";
        String username = (args.length > 1) ? args[1] : "unknown";

        WhirledApp app = new WhirledApp();
        app.init(username, gameId);
        app.run(username);
    }

    protected WhirledClient _client;
    protected ManagedJFrame _frame;
    protected FrameManager _framemgr;

    protected static LocalServer _server;
}
