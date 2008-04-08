package com.whirled.contrib.simplegame {

public class SimObjectRef
{
    public static function Null () :SimObjectRef
    {
        return new SimObjectRef();
    }

    public function get object () :SimObject
    {
        return _obj;
    }

    public function get isNull () :Boolean
    {
        return (null == _obj);
    }

    // managed by ObjectDB
    internal var _obj :SimObject;
    internal var _next :SimObjectRef;
    internal var _prev :SimObjectRef;
}

}
