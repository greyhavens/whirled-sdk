package com.whirled.contrib {

import flash.events.EventDispatcher;

import flash.utils.setTimeout;

import com.threerings.util.NameValueEvent;
import com.threerings.util.ValueEvent;
import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.EntityControl;

/**
 * This class should be instantiated by any entity (a lamp, for example) that wishes to
 * synchronize with another entity (a lightswitch, for example) that is broadcasting some
 * part of its state using a {@link EntityStatePublisher}.
 *
 * When we intercept a state change signal with the right key, we dispatch an event which
 * our instantiating entity may respond to. When first instantiated, we send out a special
 * signal that request a re-broadcast of the publisher's state.
 */
public class EntityStateListener extends EventDispatcher
{
    public function EntityStateListener (control :EntityControl, key :String)
    {
        _key = key;
        _control = control;
        _control.requestControl();
        _control.addEventListener(ControlEvent.SIGNAL_RECEIVED, handleSignal);

        // we would like to know what the current state is, and we can ask for it to be
        // rebroadcast, but if a room loads with 10 listeners we don't want 10 identical
        // requests sent out at the same time... so after we start up, we wait a little
        // while (random variation) to see if the state is either published or requested
        _needInitialRequest = true;
        setTimeout(maybeRequestInitialState, 1000 + Math.random()*1000);
    }

    public function get state () :Object
    {
        return _state;
    }

    protected function maybeRequestInitialState () :void
    {
        // TODO: this is really not satisfactory, there is NO way to know if control
        // has been assigned yet, so this test could be false for all the instances
        // in the room
        if (_needInitialRequest && _control.hasControl()) {
            _needInitialRequest = false;
            _control.sendSignal("_q_" + _key);
        }
    }

    protected function handleSignal (event :ControlEvent) :void
    {
        Log.getLog(this).debug("handleSignal(" + event + ")");
        if (event.name == "_s_" + _key) {
            _needInitialRequest = false;

            if (_stateSet == false || event.value != _state) {
                _stateSet = true;
                _state = event.value;
                dispatchEvent(new EntityStateEvent(EntityStateEvent.STATE_CHANGED, _key, _state));
            }

        } else if (event.name == "_q_" + _key) {
            _needInitialRequest = false;
        }
    }

    protected var _control :EntityControl;

    protected var _key :String;
    protected var _state :Object;

    protected var _stateSet :Boolean;

    protected var _needInitialRequest :Boolean;
}
}
