//
// $Id$
//
// @project@ - an AVR game for Whirled

package {

import flash.display.Sprite;

import flash.events.Event;

import com.whirled.avrg.AVRGameControl;

public class @project@ extends Sprite
{
    public function @project@ ()
    {
        _control = new AVRGameControl(this);

        // listen for an unload event
        _control.addEventListener(Event.UNLOAD, handleUnload);
    }

    /**
     * This is called when your game is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
    }

    protected var _control :AVRGameControl;
}
}
