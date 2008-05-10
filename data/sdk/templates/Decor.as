//
// $Id$
//
// @project@ - room decor for Whirled

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import com.whirled.DecorControl;
import com.whirled.ControlEvent;

/**
 * @project@ is the coolest Decor ever.
 */
[SWF(width="1000", height="500")]
public class @project@ extends Sprite
{
    public static const WIDTH :int = 1000;
    public static const HEIGHT :int = 500;

    public function @project@ ()
    {
        // listen for an unload event
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // instantiate and wire up our control
        _control = new DecorControl(this);

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

    protected var _control :DecorControl;
}
}
