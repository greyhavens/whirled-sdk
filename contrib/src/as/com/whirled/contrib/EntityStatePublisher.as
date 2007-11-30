package com.whirled.contrib {

import com.whirled.ControlEvent;
import com.whirled.EntityControl;

import com.threerings.util.Log;

/**
 * It is common for an item in a room to persist a memory that it wants to always be
 * shared in its environment. While this is not a difficult operation, it can clutter
 * up an otherwise tiny script. This class tries to offload the cryptic incantations
 * as much as possible.
 *
 * Typical use is this:
 *
 *   _publisher = new EntityStatePublisher(_control, KEY, false, stateUpdated);
 *
 * where _control is any EntityControl, KEY is the unique identifier used for storing
 * the memory persistently and sharing in the room properties, and stateUpdated is an
 * optional method that's called when the room state changes: this method should take
 * a String argument (the key) and an Object (the value).
 *
 * To modify the stored state, use
 *
 *   _publisher.setState(newState);
 *
 * and the current state is always available as
 *
 *  _published.state
 *
 * NOTE: This class only propagates changes made through setState(). It does not
 * listen to item memory changes.
 */
public class EntityStatePublisher
{
    public function EntityStatePublisher (control :EntityControl, key :String,
                                          defVal :Object = null, updated :Function = null)
    {
        _key = key;
        _control = control;
        if (updated != null) {
            _control.addEventListener(
                ControlEvent.MEMORY_CHANGED, function (evt :ControlEvent) :void {
                    updated(_key, evt.value);
                });
        }

        setState(_control.lookupMemory(key, defVal));
    }

    public function get state () :Object
    {
        return _control.lookupMemory(_key);
    }

    /**
     * Publish a new value to this item's persistent storage and also broadcast it to
     * the room at large as a room property. This method returns true if all went well
     * and false if something failed due to e.g. size requirements on the entry.
     */
    public function setState (state :Object) :Boolean
    {
        if (!_control.setRoomProperty(_key, state)) {
            Log.getLog(this).warning(
                "Setting room property failed [key=" + _key + ", value=" + state + "]");
            return false;
        }
        if (!_control.updateMemory(_key, state)) {
            Log.getLog(this).warning(
                "Setting item memory failed [key=" + _key + ", value=" + state + "]");
            return false;
        }
        return true;
    }

    protected var _key :String;
    protected var _control :EntityControl;
}
}
