//
// $Id$
//
// @project@ - room decor for Whirled

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import com.whirled.BackdropControl;
import com.whirled.ControlEvent;

/**
 * @project@ is the coolest Decor ever.
 */
[SWF(width="800", height="494")] // or, whatever size you want!
public class @project@ extends Sprite
{
    public static const WIDTH :int = 800;
    public static const HEIGHT :int = 494;

    public function @project@ ()
    {
        // instantiate and wire up our control
        _control = new BackdropControl(this);

        // listen for an unload event
        _control.addEventListener(Event.UNLOAD, handleUnload);
 

        // To listen for action events, uncomment this
        // _control.addEventListener(ControlEvent.ACTION_TRIGGERED, handleActionTriggered);

        // To listen for memory events, uncomment this
        // _control.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);
    }

    /**
     * This is called when an action event is triggered.
     */
    protected function handleActionTriggered (event :ControlEvent) :void
    {
        trace("action triggered: " + event.name + ", value: " + event.value);
    }

    /**
     * This is called when your decor's memory is updated.
     */
    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        trace("memory changed: " + event.name + " -> " + event.value);
    }

    /**
     * This is called when your furni is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
    }

    protected var _control :BackdropControl;
}
}
