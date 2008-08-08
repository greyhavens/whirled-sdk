//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg.server {

import com.whirled.AbstractControl;

import com.whirled.avrg.GameSubControl;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 */
public class PlayerServerSubControl extends GameSubControl
    implements MessageSubControl
{
    /** @private */
    public function PlayerServerSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    /** Sends a message to this player only. */
    public function sendMessage (name :String, value :Object) :void
    {
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return super.createSubControls();
    }
}
}
