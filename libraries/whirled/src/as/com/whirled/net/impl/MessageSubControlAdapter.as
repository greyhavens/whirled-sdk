//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.net.impl {

import com.whirled.AbstractSubControl;
import com.whirled.net.MessageSubControl;

public class MessageSubControlAdapter extends AbstractSubControl
    implements MessageSubControl
{
    public function MessageSubControlAdapter (sendMessage :Function)
    {
        _sendMessage = sendMessage;
    }

    /** @inheritDoc */
    public function sendMessage (name :String, value :Object) :void
    {
        _sendMessage(name, value);
    }

    /** @private */
    protected var _sendMessage :Function;
}
}
