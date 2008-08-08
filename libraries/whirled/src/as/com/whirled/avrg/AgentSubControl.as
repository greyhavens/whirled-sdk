//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.net.MessageSubControl;

/**
 */
public class AgentSubControl extends AbstractSubControl
    implements MessageSubControl
{
    /** @private */
    public function AgentSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

   public function sendMessage (name :String, value :Object) :void
    {
        // TODO
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            ];
    }
}
}
