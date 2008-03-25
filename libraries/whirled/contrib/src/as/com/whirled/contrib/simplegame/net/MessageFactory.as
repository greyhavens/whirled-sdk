package com.whirled.contrib.simplegame.net {

public interface MessageFactory
{
    function serialize (msg :Message) :Object;
    function deserialize (obj: Object) :Message;
}

}
