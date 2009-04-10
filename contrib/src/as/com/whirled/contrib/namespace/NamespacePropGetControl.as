package com.whirled.contrib.namespace {

import com.threerings.util.StringUtil;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.events.EventDispatcher;

/**
 * Dispatched when a property has changed in the shared game state. This event is a result
 * of calling set() or testAndSet().
 *
 * @eventType com.whirled.game.PropertyChangedEvent.PROPERTY_CHANGED
 */
[Event(name="PropChanged", type="com.whirled.net.PropertyChangedEvent")]

/**
 * Dispatched when an element inside a property has changed in the shared game state.
 * This event is a result of calling setIn() or setAt().
 *
 * @eventType com.whirled.game.ElementChangedEvent.ELEMENT_CHANGED
 */
[Event(name="ElemChanged", type="com.whirled.net.ElementChangedEvent")]

public class NamespacePropGetControl extends EventDispatcher
    implements PropertyGetSubControl
{
    public function NamespacePropGetControl (theNamespace :String,
        propGetCtrl :PropertyGetSubControl)
    {
        _theNamespace = theNamespace;
        _nameUtil = new NameUtil(_theNamespace);
        _propGetCtrl = propGetCtrl;

        _propGetCtrl.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        _propGetCtrl.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
    }

    public function shutdown () :void
    {
        _propGetCtrl.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        _propGetCtrl.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
    }

    public function get theNamespace () :String
    {
        return _theNamespace;
    }

    public function get (propName :String) :Object
    {
        return _propGetCtrl.get(_nameUtil.encode(propName));
    }

    public function getPropertyNames (prefix :String = "") :Array
    {
        var outNames :Array = [];
        for each (var propName :String in _propGetCtrl.getPropertyNames()) {
            if (_nameUtil.isInNamespace(propName)) {
                var decoded :String = _nameUtil.decode(propName);
                if (StringUtil.startsWith(decoded, prefix)) {
                    outNames.push(decoded);
                }
            }
        }

        return outNames;
    }

    public function getTargetId () :int
    {
        return _propGetCtrl.getTargetId();
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (_nameUtil.isInNamespace(e.name)) {
            dispatchEvent(new PropertyChangedEvent(
                PropertyChangedEvent.PROPERTY_CHANGED,
                _nameUtil.decode(e.name),
                e.newValue,
                e.oldValue));
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (_nameUtil.isInNamespace(e.name)) {
            dispatchEvent(new ElementChangedEvent(
                ElementChangedEvent.ELEMENT_CHANGED,
                _nameUtil.decode(e.name),
                e.newValue,
                e.oldValue,
                e.key));
        }
    }

    protected var _theNamespace :String;
    protected var _nameUtil :NameUtil;
    protected var _propGetCtrl :PropertyGetSubControl;
}

}
