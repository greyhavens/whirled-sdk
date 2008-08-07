package com.whirled.net.impl {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.net.PropertySubControl;

public class PropertySubControlImpl extends PropertyGetSubControlImpl
    implements PropertySubControl
{
    public function PropertySubControlImpl (ctrl :AbstractControl, hookPrefix :String)
    {
        super(ctrl, hookPrefix);
    }

    // from PropertyGetSubControl
    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        callHostCode(_hookPrefix + "_setProperty_v2", propName, value, null, false, immediate);
    }

    // from PropertyGetSubControl
    public function setAt (
        propName :String, index :int, value :Object, immediate :Boolean = false) :void
    {
        callHostCode(_hookPrefix + "_setProperty_v2", propName, value, index, true, immediate);
    }

    // from PropertyGetSubControl
    public function setIn (
        propName :String, key :int, value :Object, immediate :Boolean = false) :void
    {
        callHostCode(_hookPrefix + "_setProperty_v2", propName, value, key, false, immediate);
    }

    // from PropertyGetSubControl
    public function testAndSet (propName :String, newValue :Object, testValue :Object) :void
    {
        callHostCode(_hookPrefix + "_testAndSetProperty_v1", propName, newValue, testValue);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
    }
}
}
