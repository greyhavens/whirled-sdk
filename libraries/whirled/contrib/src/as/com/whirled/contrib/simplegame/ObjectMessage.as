package com.whirled.contrib.simplegame {

public class ObjectMessage
{
    public function ObjectMessage (name :String, data :* = null)
    {
        _name = name;
        _data = data;
    }

    public function get name () :String
    {
        return _name;
    }

    public function get data () :*
    {
        return _data;
    }

    protected var _name :String;
    protected var _data :*;

}

}
