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

import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;

import flash.events.EventDispatcher;

public class NamespaceMessageControl extends EventDispatcher
    implements MessageSubControl
{
    public function NamespaceMessageControl (theNamespace :String, msgCtrl :MessageSubControl,
        msgReceiver :EventDispatcher = null)
    {
        _nameUtil = new NameUtil(theNamespace);
        if (msgReceiver != null) {
            _events.registerListener(msgReceiver, MessageReceivedEvent.MESSAGE_RECEIVED,
                onMsgReceived);
        }
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    public function sendMessage (name :String, value :Object = null) :void
    {
        _msgCtrl.sendMessage(_nameUtil.encode(name), value);
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (_nameUtil.isInNamespace(e.name)) {
            dispatchEvent(new MessageReceivedEvent(_nameUtil.decode(e.name), e.value));
        }
    }

    protected var _nameUtil :NameUtil;
    protected var _msgCtrl :MessageSubControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
