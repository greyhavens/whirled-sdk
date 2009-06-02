package com.whirled.contrib.simplegame {

import com.whirled.contrib.simplegame.resource.ResourceManager;

public class Config
{
    /** The number of audio channels the AudioManager will use. Optional. Defaults to 25. */
    public var maxAudioChannels :int = 25;

    /**
     * If not null, externalResourceManager will be used in place of a new ResourceManager.
     * externalResourceManager will not be shut down when the SimpleGame is.
     * Defaults to null.
     */
    public var externalResourceManager :ResourceManager;
}

}
