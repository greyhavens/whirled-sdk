package com.whirled.contrib {

import flash.events.EventDispatcher;

import flash.utils.setTimeout;

import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.EntityControl;

/**
 * This class should be instantiated by any entity (a lamp, for example) that wishes to
 * synchronize with another entity (a lightswitch, for example) that is broadcasting some
 * part of its state using a @see EntityStatePublisher .
 */
public class EntityStateListener extends EventDispatcher
{
    public function EntityStateListener (
        control :EntityControl, key :String, updated :Function = null)
    {
        _key = key;
        _control = control;
        if (updated != null) {
            _updated = updated;
            _control.addEventListener(ControlEvent.ROOM_PROPERTY_CHANGED, handlePropertyChanged);
        }
    }

    public function get state () :Object
    {
        return _control.getRoomProperty(_key);
    }

    protected function handlePropertyChanged (event :ControlEvent) :void
    {
        if (event.name == _key) {
            _updated(_key, event.value);
        }
    }

    protected var _control :EntityControl;
    protected var _key :String;
    protected var _updated :Function;
}
}
