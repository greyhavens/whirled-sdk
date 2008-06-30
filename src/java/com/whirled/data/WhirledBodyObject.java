//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledGameOccupantInfo;

/**
 * A body object for a tester client.
 */
public class WhirledBodyObject extends BodyObject
{
    @Override
    public OccupantInfo createOccupantInfo (PlaceObject plObj)
    {
        if (plObj instanceof WhirledGameObject) {
            return new WhirledGameOccupantInfo(this);

        } else {
            return super.createOccupantInfo(plObj);
        }
    }
}
