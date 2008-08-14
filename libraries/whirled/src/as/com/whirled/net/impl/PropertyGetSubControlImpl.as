//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.net.impl {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.TargetedSubControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.PropertyChangedEvent;

public class PropertyGetSubControlImpl extends TargetedSubControl
    implements PropertyGetSubControl
{
    public function PropertyGetSubControlImpl (
        ctrl :AbstractControl, targetId :int, fn_propertyWasSet :String, fn_getGameData :String)
    {
        _fn_propertyWasSet = fn_propertyWasSet;
        _fn_getGameData = fn_getGameData;
        super(ctrl, targetId);
    }

    /** @inheritDoc */
    public function get (propName :String) :Object
    {
        return _gameData[propName];
    }

    /** @inheritDoc */
    public function getPropertyNames (prefix :String = "") :Array
    {
        var props :Array = [];
        for (var s :String in _gameData) {
            if (s.lastIndexOf(prefix, 0) == 0) {
                props.push(s);
            }
        }
        return props;
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        if (_fn_propertyWasSet != null) {
            o[_fn_propertyWasSet] = propertyWasSet;
        }
    }

    /** @private */
    override protected function gotHostProps (o :Object) :void
    {
        super.gotHostProps(o);

        _gameData = o[_fn_getGameData].call(null, _targetId);
    }

    /**
     * Private method to post a PropertyChangedEvent.
     */
    private function propertyWasSet (
        name :String, newValue :Object, oldValue :Object, key :Object) :void
    {
        if (key == null) {
            dispatch(new PropertyChangedEvent(PropertyChangedEvent.PROPERTY_CHANGED,
                                              _targetId, name, newValue, oldValue));
        } else {
            dispatch(new ElementChangedEvent(ElementChangedEvent.ELEMENT_CHANGED,
                                             _targetId, name, newValue, oldValue, int(key)));
        }
    }

    /** Game properties. @private */
    protected var _gameData :Object;

    /** @private */
    protected var _fn_propertyWasSet :String;
    /** @private */
    protected var _fn_getGameData :String;
}
}
