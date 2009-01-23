//
// $Id$

package com.whirled.client;

import com.google.inject.Guice;
import com.google.inject.Injector;

import com.samskivert.swing.util.SwingUtil;

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
        _frame.setSize(1024, 600);
        SwingUtil.centerWindow(_frame);

        // create and initialize our client instance
        _client = new WhirledTestClient();
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
        // start up our local server
        Injector injector = Guice.createInjector(new LocalServer.Module());
        _server = injector.getInstance(LocalServer.class);
        _server.init(injector);

        String gameId = (args.length > 0) ? args[0] : "unknown";
        String username = (args.length > 1) ? args[1] : "unknown";

        WhirledApp app = new WhirledApp();
        app.init(username, gameId);
        app.run(username);
    }

    protected WhirledTestClient _client;
    protected ManagedJFrame _frame;
    protected FrameManager _framemgr;

    protected static LocalServer _server;
}
