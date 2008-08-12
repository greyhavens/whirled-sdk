//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 */
public class GameSubControl extends AbstractSubControl
{
    /** @private */
    public function GameSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    public function get props () :PropertyGetSubControl
    {
        return _props;
    }

    public function getPlayerIds () :Array
    {
        return callHostCode("getGamePlayerIds_v1") as Array;
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["coinsAwarded_v1"] = coinsAwarded_v1;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertyGetSubControlImpl(
            _parent, 0, "game_propertyWasSet", "game_getGameData");
        return [ _props ];
    }

    /** @private */
    protected function coinsAwarded_v1 (amount :int) :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.COINS_AWARDED, null, amount));
    }

    protected var _props :PropertyGetSubControl;
}
}
