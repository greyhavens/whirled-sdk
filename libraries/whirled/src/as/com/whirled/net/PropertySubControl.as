package com.whirled.net {

public interface PropertySubControl extends PropertyGetSubControl
{
    function set (propName :String, value :Object, immediate :Boolean = false) :void;
    function setAt (propName :String, index :int, value :Object, immediate :Boolean = false) :void;
    function setIn (propName :String, key :int, value :Object, immediate :Boolean = false) :void;
    function testAndSet (propName :String, newValue :Object, testValue :Object) :void;
}
}
