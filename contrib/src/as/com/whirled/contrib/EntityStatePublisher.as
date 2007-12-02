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
 */
public class EntityStatePublisher extends EntityStateListener
{
    public function EntityStatePublisher (control :EntityControl, key :String,
                                          defVal :Object = null, updated :Function = null)
    {
        super(control, key, updated);

        setState(_control.lookupMemory(key, defVal));
    }

    /**
     * Publish a new value to this item's persistent storage and also broadcast it to
     * the room at large as a room property. This method returns true if all went well
     * and false if something failed due to e.g. size requirements on the entry.
     */
    public function setState (newState :Object) :Boolean
    {
        if (newState != _control.getRoomProperty(_key)) {
            if (!_control.setRoomProperty(_key, newState)) {
                Log.getLog(this).warning(
                    "Setting room property failed [key=" + _key + ", value=" + newState + "]");
                return false;
            }
        }
        if (newState != _control.lookupMemory(_key)) {
            if (!_control.updateMemory(_key, newState)) {
                Log.getLog(this).warning(
                    "Setting item memory failed [key=" + _key + ", value=" + newState + "]");
                return false;
            }
        }
        return true;
    }
}
}
