package com.whirled.contrib.core {

public class ObjectMessage
{
    public function ObjectMessage (name :String, sourceId :uint = 0)
    {
        _sourceId = sourceId;
    }

    public function get sourceId () :uint
    {
        return _sourceId;
    }

    public function get name () :String
    {
        return _name;
    }

    protected var _name :String;
    protected var _sourceId :uint;

}

}
