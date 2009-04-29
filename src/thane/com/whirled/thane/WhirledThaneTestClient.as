//
// $Id$

package com.whirled.thane {

import avmplus.System;
import com.whirled.bureau.client.WhirledBureauClient;
import com.whirled.thane.HttpUserCodeLoader;
import com.whirled.game.client.ThaneGameController;
import com.whirled.game.client.TestUserIdentifier;

public class WhirledThaneTestClient
{
    ThaneGameController.setUserIdentifier(new TestUserIdentifier());
    WhirledBureauClient.main(System.argv, "0", new HttpUserCodeLoader(), cleanup);

    protected static function cleanup (client :WhirledBureauClient) :void
    {
        trace("Exiting bureau");
        System.exit(0);
    }
}
}
