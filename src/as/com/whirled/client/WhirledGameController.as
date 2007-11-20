//
// $Id$

package com.whirled.client {

import com.threerings.presents.dobj.SetListener;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;

import com.threerings.crowd.data.PlaceObject;

import com.threerings.ezgame.client.EZGameController;

public class WhirledGameController extends EZGameController
    implements SetListener
{
    /**
     * Request to leave the game.
     */
    public function backToWhirled (showLobby :Boolean = false) :void
    {
        throw new Error("abstract");
    }

    // from SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            (_view as WhirledGamePanel).checkRematchVisibility();
        }
    }

    // from SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            (_view as WhirledGamePanel).checkRematchVisibility();
        }
    }

    // from SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        // nada
    }

    override protected function gameDidStart () :void
    {
        super.gameDidStart();

        (_view as WhirledGamePanel).checkRematchVisibility();
    }

    override protected function gameDidEnd () :void
    {
        super.gameDidEnd();

        (_view as WhirledGamePanel).checkRematchVisibility();
    }
}
}
