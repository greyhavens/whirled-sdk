//
// $Id$

package com.whirled.game.loopback {

import flash.display.DisplayObject;

import flash.events.Event;

import com.whirled.game.GameControl;

public class LoopbackGameControl extends GameControl
{
    public function LoopbackGameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        disp.root.loaderInfo.sharedEvents.addEventListener(
            "controlConnect", handleConnect, false, int.MAX_VALUE);
        super(disp, autoReady);
    }

    // From here we act like Base
    protected function handleConnect (event :Event) :void
    {
        event.stopImmediatePropagation();

        // Do everything that BaseGameBackend does

        var props :Object = Object(event).props;
        var userProps :Object = props.userProps;

        trace("AutoReady set to " + userProps["autoReady_v1"]);


        // Here ya go, Tim.
    }
}

}
