package com.whirled.contrib.simplegame {

import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Sprite;
import flash.events.IEventDispatcher;

public class SimpleGame
{
    public function SimpleGame (config :Config)
    {
        _ctx.mainLoop = new MainLoop(_ctx);
        _ctx.audio = new AudioManager(_ctx, config.maxAudioChannels);
        _ctx.mainLoop.addUpdatable(_ctx.audio);

        if (config.externalResourceManager != null) {
            _ctx.rsrcs = new ResourceManager();
            _ownsResourceManager = true;

            // add resource factories
            _ctx.rsrcs.registerResourceType("image", ImageResource);
            _ctx.rsrcs.registerResourceType("swf", SwfResource);
            _ctx.rsrcs.registerResourceType("xml", XmlResource);
            _ctx.rsrcs.registerResourceType("sound", SoundResource);

        } else {
            _ctx.rsrcs = config.externalResourceManager;
            _ownsResourceManager = false;
        }
    }

    public function run (hostSprite :Sprite, keyDispatcher :IEventDispatcher = null) :void
    {
        _ctx.mainLoop.setup();
        _ctx.mainLoop.run(hostSprite, keyDispatcher);
    }

    public function shutdown () :void
    {
        _ctx.mainLoop.shutdown();
        _ctx.audio.shutdown();

        if (_ownsResourceManager) {
            _ctx.rsrcs.shutdown();
        }
    }

    public function get ctx () :SGContext
    {
        return _ctx;
    }

    protected var _ctx :SGContext = new SGContext();
    protected var _ownsResourceManager :Boolean;
}

}
