//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

/**
 * Defines actions, accessors and callbacks available to all Pets.
 */
public class PetControl extends ActorControl
{
    /**
     * Creates a controller for a Pet. The display object is the Pet's visualization.
     */
    public function PetControl (disp :DisplayObject)
    {
        super(disp);
    }

    /**
     * Send a chat message to the entire room. The chat message will be treated as if it
     * were typed in at the chat message box - it will be filtered, and any action commands
     * (e.g. /emote) will be handled appropriately.
     */
    public function sendChatMessage (msg :String) :void
    {
        callHostCode("sendChatMessage_v1", msg);
    }

    // from WhirledControl
    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        // TODO
    }

    override protected function isAbstract () :Boolean
    {
        return false;
    }
}
}
