//
// $Id$

package com.whirled.server;

import java.util.List;

import com.google.common.collect.Lists;

import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.server.PlaceManagerDelegate;

import com.threerings.parlor.game.data.GameConfig;
import com.threerings.parlor.server.ParlorManager;

public class WhirledParlorManager extends ParlorManager
{
    @Override
    protected void createGameManager (GameConfig config)
        throws InstantiationException, InvocationException
    {
        List<PlaceManagerDelegate> delegates = Lists.newArrayList();
        delegates.add(new WhirledGameManagerDelegate());
        _plreg.createPlace(config, delegates);
    }
}
