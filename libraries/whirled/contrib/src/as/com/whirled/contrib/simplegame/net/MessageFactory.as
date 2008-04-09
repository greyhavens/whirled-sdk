package com.whirled.contrib.simplegame.net {

public interface MessageFactory
{
    function serializeForNetwork (msg :Message) :Object;
    function deserializeFromNetwork (obj: Object) :Message;
}

}
