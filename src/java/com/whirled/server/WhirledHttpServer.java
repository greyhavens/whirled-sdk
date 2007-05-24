//
// $Id$

package com.whirled.server;

import java.io.File;
import java.util.Enumeration;

import java.util.logging.Level;
import java.util.logging.LogManager;
import java.util.logging.Logger;

import org.mortbay.http.HttpContext;
import org.mortbay.http.HttpServer;
import org.mortbay.http.handler.ResourceHandler;

import static com.whirled.Log.log;

/**
 * Handles HTTP requests from the Flash client to load the game SWF.
 */
public class WhirledHttpServer extends HttpServer
{
    /**
     * Creates and prepares our HTTP server for operation but does not yet
     * start listening on the HTTP port.
     */
    public WhirledHttpServer ()
    {
        // wire up serving of static content
        HttpContext context = getContext("/");
        context.setResourceBase(new File("").getAbsolutePath());
        context.addHandler(new ResourceHandler());
        log.info("Resource base " + new File("").getAbsolutePath());

        // tone down the default verbose logging; unfortunately it creates a new logger and logs
        // verbosely to it before we get a chance to shut it the fuck up, but it's mostly minimal
        LogManager logmgr = LogManager.getLogManager();
        for (Enumeration<String> iter = logmgr.getLoggerNames(); iter.hasMoreElements(); ) {
            String name = iter.nextElement();
            if (name.startsWith("org.mortbay")) {
                Logger logger = logmgr.getLogger(name);
                logger.setLevel(Level.WARNING);
            }
        }
    }

    /**
     * Initializes our HTTP server and begins listening for connections.
     */
    public void init ()
        throws Exception
    {
        addListener(":8080");
        start();
    }
}
