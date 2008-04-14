package com.whirled.contrib.simplegame.net {

import com.whirled.contrib.simplegame.Updatable;

public interface TickedMessageManager extends Updatable
{
    function setup () :void;
    function shutdown () :void;

    function get isReady () :Boolean;
    function get randomSeed () :uint;

    function get unprocessedTickCount () :uint;
    function getNextTick () :Array;

    function addMessageFactory (messageName :String, factory :MessageFactory) :void;
    function sendMessage (msg :Message) :void;
    function canSendMessage () :Boolean;
}

}
