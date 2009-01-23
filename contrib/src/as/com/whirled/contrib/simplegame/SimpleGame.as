package com.whirled.contrib.simplegame {

import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;

public class SimpleGame
{
    public function SimpleGame (config :Config)
    {
        if (config.hostSprite == null) {
            throw new Error("Config.hostSprite must not be null");
        }

        _ctx.mainLoop = new MainLoop(_ctx, config.hostSprite, config.keyDispatcher);
        _ctx.audio = new AudioManager(_ctx, config.maxAudioChannels);
        _ctx.rsrcs = new ResourceManager(_ctx);

        // add resource factories
        _ctx.rsrcs.registerResourceType("image", ImageResource);
        _ctx.rsrcs.registerResourceType("swf", SwfResource);
        _ctx.rsrcs.registerResourceType("xml", XmlResource);
        _ctx.rsrcs.registerResourceType("sound", SoundResource);

        _ctx.mainLoop.addUpdatable(_ctx.audio);
    }

    public function run () :void
    {
        _ctx.mainLoop.setup();
        _ctx.mainLoop.run();
    }

    public function shutdown () :void
    {
        _ctx.mainLoop.shutdown();
        _ctx.audio.shutdown();
        _ctx.rsrcs.shutdown();
    }

    public function get ctx () :SGContext
    {
        return _ctx;
    }

    protected var _ctx :SGContext = new SGContext();
}

}
