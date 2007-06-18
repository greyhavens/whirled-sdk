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
public class TestGameControlBackend extends GameControlBackend
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

//         var ctrl :MsoyGameController = (_ctrl as MsoyGameController);
//         o["getAvailableFlow_v1"] = ctrl.getAvailableFlow_v1;
//         o["awardFlow_v1"] = ctrl.awardFlow_v1;
//         o["setChatEnabled_v1"] = ctrl.setChatEnabled_v1;
//         o["setChatBounds_v1"] = ctrl.setChatBounds_v1;
//         o["getHeadShot_v1"] = getHeadShot_v1;
        o["getStageBounds_v1"] = getStageBounds_v1;
    }

//     protected function getHeadShot_v1 (occupant :int, callback :Function) :void
//     {
//         validateConnected();
//         var info :GameMemberInfo = _ezObj.occupantInfo.get(occupant) as GameMemberInfo;
//         if (info != null) {
//             var headshot :Headshot = _headshots[occupant];
//             if (headshot == null) {
//                 _headshots[occupant] = headshot = new Headshot(info.headShot.getMediaPath());
//             }
//             headshot.newRequest(callback);
//             return;
//         }
//         throw new Error("Failed to find occupant: " + occupant);
//     }

    protected function getStageBounds_v1 () :Rectangle
    {
        return _panel.getStageBounds();
    }

    protected var _panel :TestGamePanel;
}
}
