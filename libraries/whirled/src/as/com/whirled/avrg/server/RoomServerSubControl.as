//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg.server {

import com.whirled.AbstractControl;

import com.whirled.avrg.RoomSubControl;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 */
public class RoomServerSubControl extends RoomSubControl
    implements MessageSubControl
{
    /** @private */
    public function RoomServerSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    public function spawnMob (id :String, name :String) :Boolean
    {
        return callHostCode("spawnMob_v1", id, name);
    }

    public function despawnMob (id :String) :Boolean
    {
        return callHostCode("despawnMob_v1", id);
    }

    /** Sends a message to all the players that are in the room. */
    public function sendMessage (name :String, value :Object) :void
    {
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return super.createSubControls();
    }
}
}
