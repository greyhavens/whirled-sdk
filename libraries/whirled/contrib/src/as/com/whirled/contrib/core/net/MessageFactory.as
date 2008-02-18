package com.whirled.contrib.core.net {

public interface MessageFactory
{
    function serialize (msg :Message) :Object;
    function deserialize (obj: Object) :Message;
}

}
