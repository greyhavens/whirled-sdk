package com.whirled.contrib.namespc {

import com.whirled.net.PropertySubControl;

public class NamespacePropControl extends NamespacePropGetControl
    implements PropertySubControl
{
    public function NamespacePropControl (theNamespace :String, propCtrl :PropertySubControl)
    {
        super(theNamespace, propCtrl);
        _propCtrl = propCtrl;
    }

    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        _propCtrl.set(_nameUtil.encode(propName), value, immediate);
    }

    public function setAt (propName :String, index :int, value :Object, immediate :Boolean = false)
        :void
    {
        _propCtrl.setAt(_nameUtil.encode(propName), index, value, immediate);
    }

    public function setIn (propName :String, key :int, value :Object, immediate :Boolean = false)
        :void
    {
        _propCtrl.setIn(_nameUtil.encode(propName), key, value, immediate);
    }

    protected var _propCtrl :PropertySubControl;
}

}
