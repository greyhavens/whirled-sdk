package com.whirled.net.impl {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.HookSubControl;

import com.whirled.game.ElementChangedEvent;
import com.whirled.game.PropertyChangedEvent;

/**
 * Dispatched when a property has changed in the shared game state. This event is a result
 * of calling set() or testAndSet().
 *
 * @eventType com.whirled.game.PropertyChangedEvent.PROPERTY_CHANGED
 */
[Event(name="PropChanged", type="com.whirled.game.PropertyChangedEvent")]

/**
 * Dispatched when an element inside a property has changed in the shared game state.
 * This event is a result of calling setIn() or setAt().
 *
 * @eventType com.whirled.game.ElementChangedEvent.ELEMENT_CHANGED
 */
[Event(name="ElemChanged", type="com.whirled.game.ElementChangedEvent")]

public class PropertyGetSubControlImpl extends HookSubControl
    implements PropertyGetSubControl
{
    public function PropertyGetSubControlImpl (ctrl :AbstractControl, hookPrefix :String)
    {
        super(ctrl, hookPrefix);
    }

    // from PropertyGetSubControl
    public function get (propName :String) :Object
    {
        return _gameData[propName];
    }

    // from PropertyGetSubControl
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

        o[_hookPrefix + "_propertyWasSet_v2"] = propertyWasSet_v2;

        _gameData = o[_hookPrefix + "_gameData"];
    }

    /**
     * Private method to post a PropertyChangedEvent.
     */
    private function propertyWasSet_v2 (
        name :String, newValue :Object, oldValue :Object, key :Object) :void
    {
        if (key == null) {
            dispatch(new PropertyChangedEvent(PropertyChangedEvent.PROPERTY_CHANGED,
                name, newValue, oldValue));
        } else {
            dispatch(new ElementChangedEvent(ElementChangedEvent.ELEMENT_CHANGED,
                name, newValue, oldValue, int(key)));
        }
    }

    /** Game properties. @private */
    protected var _gameData :Object;
}
}
