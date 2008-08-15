//
// $Id$

package com.whirled.game.data;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

/**
 * Body for playing whirled games.
 */
public class WhirledPlayerObject extends BodyObject
{
    @Override public OccupantInfo createOccupantInfo (PlaceObject plObj)
    {
        if (plObj instanceof WhirledGameObject) {
            return new WhirledGameOccupantInfo(this);

        } else {
            return super.createOccupantInfo(plObj);
        }
    }
}
