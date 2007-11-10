//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.ezgame.server.EZGameManager;

import com.whirled.data.TestGameObject;

/**
 * Handles test game services.
 */
public class TestGameManager extends EZGameManager
{
    @Override // from PlaceManager
    protected PlaceObject createPlaceObject ()
    {
        return new TestGameObject();
    }
}
