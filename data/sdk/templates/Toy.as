//
// $Id$
//
// @project@ - a toy for Whirled

package {

import flash.display.Sprite;

import flash.events.Event;

import com.whirled.ToyControl;
import com.whirled.ControlEvent;

/**
 * @project@ is the coolest toy ever.
 */
[SWF(width="100", height="100")]
public class @project@ extends Sprite
{
    public static const WIDTH :int = 100;
    public static const HEIGHT :int = 100;

    public function @project@ ()
    {
        // instantiate and wire up our control
        _control = new ToyControl(this);
        _control.addEventListener(Event.UNLOAD, handleUnload);

        // To listen for memory events, uncomment this
        // _control.addEventListener(ControlEvent.MEMORY_CHANGED, memoryChanged);
    }

    /**
     * This is called when your toy's memory is updated.
     */
    protected function memoryChanged (event :ControlEvent) :void
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

    protected var _control :ToyControl;
}
}
