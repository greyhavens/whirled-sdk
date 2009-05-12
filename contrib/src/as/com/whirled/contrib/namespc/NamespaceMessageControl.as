// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2009 Three Rings Design
//
// $Id$

package com.whirled.contrib.namespc {

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;

import flash.events.EventDispatcher;

public class NamespaceMessageControl extends EventDispatcher
    implements MessageSubControl
{
    public function NamespaceMessageControl (theNamespace :String, outMsg :MessageSubControl = null,
        inMsg :EventDispatcher = null)
    {
        _nameUtil = new NameUtil(theNamespace);
        _outMsg = outMsg;
        _inMsg = inMsg;

        if (_inMsg != null) {
            _inMsg.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);
        }
    }

    public function shutdown () :void
    {
        if (_inMsg != null) {
            _inMsg.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);
        }
    }

    public function sendMessage (name :String, value :Object = null) :void
    {
        if (_outMsg != null) {
            _outMsg.sendMessage(_nameUtil.encode(name), value);
        }
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (_nameUtil.isInNamespace(e.name)) {
            dispatchEvent(new MessageReceivedEvent(_nameUtil.decode(e.name), e.value));
        }
    }

    protected var _nameUtil :NameUtil;
    protected var _outMsg :MessageSubControl;
    protected var _inMsg :EventDispatcher;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
