package com.whirled.contrib.namespace {

import com.threerings.util.StringUtil;

public class NameUtil
{
    public function NameUtil (theNamespace :String)
    {
        _suffix = SEPARATOR + theNamespace;
    }

    public function encode (val :String) :String
    {
        return val + _suffix;
    }

    public function decode (val :String) :String
    {
        return val.substr(0, val.length - _suffix.length);
    }

    public function isInNamespace (val :String) :Boolean
    {
        return (val.length > _suffix.length && StringUtil.endsWith(val, _suffix));
    }

    protected var _suffix :String;

    protected static const SEPARATOR :String = ":";
}

}
