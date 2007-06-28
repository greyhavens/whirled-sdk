//
// $Id$

package com.whirled.server;

import java.io.File;

import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.nio.BlockingChannelConnector;
import org.mortbay.jetty.servlet.Context;
import org.mortbay.jetty.servlet.DefaultServlet;
import org.mortbay.jetty.servlet.ServletHolder;

import static com.whirled.Log.log;

/**
 * Handles HTTP requests from the Flash client to load the game SWF.
 */
public class WhirledHttpServer extends Server
{
    /**
     * Creates and prepares our HTTP server for operation but does not yet start listening on the
     * HTTP port. Call {@link #start} to start us listening.
     */
    public WhirledHttpServer (String docroot)
    {
        BlockingChannelConnector conn = new BlockingChannelConnector();
        conn.setPort(8080);
        setConnectors(new Connector[] { conn });

        // wire up serving of static content
        Context context = new Context(this, "/", Context.NO_SESSIONS);
        context.setResourceBase(new File(docroot).getAbsolutePath());
        context.addServlet(new ServletHolder(new DefaultServlet()), "/*");
    }
}
