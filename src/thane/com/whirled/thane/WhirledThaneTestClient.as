//
// $Id$
//
// Copyright (c) 2007-2011 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.thane {

import avmplus.System;
import com.threerings.parlor.game.data.UserIdentifier;
import com.whirled.bureau.client.WhirledBureauClient;
import com.whirled.thane.HttpUserCodeLoader;
import com.whirled.game.client.TestUserIdentifier;
import com.whirled.game.client.ThaneGameController;

public class WhirledThaneTestClient
{
    UserIdentifier.setIder(TestUserIdentifier.getUserId);
    WhirledBureauClient.main(System.argv, "0", new HttpUserCodeLoader(), cleanup);

    protected static function cleanup (client :WhirledBureauClient) :void
    {
        trace("Exiting bureau");
        System.exit(0);
    }
}
}
