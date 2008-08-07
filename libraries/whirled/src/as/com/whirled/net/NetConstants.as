package com.whirled.net {

public class NetConstants
{
    /** Properties beginning with this string will be restored on the next session. */
    public static const PERSISTENT :String = "@";

    /**
     * Transform a name to a persistent name. Has no effect for names that
     * are already persistent.
     */
    public static function makePersistent (name :String) :String
    {
        // TODO;
        return name;
    }
}
}
