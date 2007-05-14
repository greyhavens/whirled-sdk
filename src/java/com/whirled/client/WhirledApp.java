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

import com.threerings.presents.client.Client;
import com.threerings.presents.net.UsernamePasswordCreds;

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
        _frame.setDefaultCloseOperation(ManagedJFrame.DO_NOTHING_ON_CLOSE);
        _framemgr = FrameManager.newInstance(_frame);

        _frame.addWindowListener(new WindowAdapter() {
            public void windowClosing (WindowEvent evt) {
                if (_client.getContext().getClient().isLoggedOn()) {
                    _client.getContext().getClient().logoff(true); // if we're logged on, log off
                }
                System.exit(0); // and get the heck out
            }
        });

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

        // configure the client with server and port
        Client client = _client.getContext().getClient();
        client.setServer("localhost", Client.DEFAULT_SERVER_PORTS);

        // configure the client with our credentials and logon
        client.setCredentials(new UsernamePasswordCreds(new Name(username), "secret"));
        client.logon();

        // start up the frame manager
        _framemgr.start();
    }

    public static void main (String[] args)
        throws Exception
    {
        com.samskivert.util.Log.setLogProvider(new LoggingLogProvider());
        OneLineLogFormatter.configureDefaultHandler();

        String gameId = (args.length > 0) ? args[0] : "unknown";
        String username = (args.length > 1) ? args[1] : "unknown";

        WhirledApp app = new WhirledApp();
        app.init(username, gameId);
        app.run(username);
    }

    protected WhirledClient _client;
    protected ManagedJFrame _frame;
    protected FrameManager _framemgr;
}
