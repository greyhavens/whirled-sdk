//
// $Id$

package com.whirled.game.client {

import com.threerings.util.Name;
import com.threerings.util.StringUtil;

import com.threerings.parlor.game.data.UserIdentifier;

public class TestUserIdentifier
    implements UserIdentifier
{
    public function getUserId (name :Name) :int
    {
        var username :String = name.toString();
        try {
            return StringUtil.parseInteger(username.substring(username.lastIndexOf("_")+1));
        } catch (e :Error) {
            // below
        }
        return -1 * Math.abs(StringUtil.hashCode(username));
    }
}
}
