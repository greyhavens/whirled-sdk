//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.client {

import flash.display.Loader;
import flash.display.Stage;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

import com.threerings.crowd.util.CrowdContext;
import com.threerings.ezgame.client.GameControlBackend;
import com.threerings.ezgame.data.EZGameObject;

/**
 * Extends the basic EZGame backend with flow and other whirled services.
 */
public class TestGameControlBackend extends WhirledGameControlBackend
{
    public function TestGameControlBackend (
        ctx :CrowdContext, ezObj :EZGameObject, ctrl :TestGameController, panel :TestGamePanel)
    {
        super(ctx, ezObj, ctrl);
        _panel = panel;
    }

    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        var ctrl :TestGameController = (_ctrl as TestGameController);
//         o["getHeadShot_v1"] = getHeadShot; // TODO: fake up a sprite
        o["backToWhirled_v1"] = backToWhirled;
    }

    protected function backToWhirled (showLobby :Boolean = false) :void
    {
        _ctx.getClient().logoff(false);
    }

    protected var _panel :TestGamePanel;
}
}
