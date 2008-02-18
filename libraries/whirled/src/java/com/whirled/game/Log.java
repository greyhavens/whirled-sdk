//
// $Id$

package com.whirled.game;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Contains a reference to the log object used by this package.
 */
public class Log
{
    /** We dispatch our log messages through this logger. */
    public static Logger log = Logger.getLogger("com.whirled.game");

    /** Convenience function. */
    public static void debug (String message)
    {
        log.fine(message);
    }

    /** Convenience function. */
    public static void info (String message)
    {
        log.info(message);
    }

    /** Convenience function. */
    public static void warning (String message)
    {
        log.warning(message);
    }

    /** Convenience function. */
    public static void logStackTrace (Throwable t)
    {
        log.log(Level.WARNING, t.getMessage(), t);
    }
}
