package com.whirled.contrib.simplegame {

import flash.display.Sprite;
import flash.events.IEventDispatcher;

public class Config
{
    /** The Sprite that is hosting this SimpleGame. Required. */
    public var hostSprite :Sprite;

    /**
     * The EventDispatcher that will deliver keyboard events to the SimpleGame.
     * In games connected to Whirled, this should be set to the game's LocalSubControl.
     * Otherwise, it can be left as null.
     */
    public var keyDispatcher :IEventDispatcher;

    /** The number of audio channels the AudioManager will use. Optional. Defaults to 25. */
    public var maxAudioChannels :int = 25;
}

}
