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
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.avrg.probe {

import com.whirled.avrg.AVRServerGameControl;
import com.whirled.net.MessageReceivedEvent;

/**
 * Class to quietly listen for the <code>ClientPanel</code> to notify that it is time to
 * instantiate a full <code>ServerModule</code> and later shut it down on request. This allows
 * the server side of the probe to lie in waiting for the client to be invoked via hidden
 * keystrokes or whatever. It is not necessary if the containing application wants to have
 * an active <code>ServerModule</code> at all times.
 */
public class ServerStub
{
    /** Message sent to activate our module. */
    public static const ACTIVATE :String = "serverStub.activate";

    /** Message sent to deacticate our module. */
    public static const DEACTIVATE :String = "serverStub.deactivate";

    /** Message sent to acknowledge the activation or deactivation. */
    public static const ACKNOWLEDGED :String = "serverStub.acknowledged";

    public function ServerStub (ctrl: AVRServerGameControl)
    {
        _ctrl = ctrl;
        _ctrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleGameMessage);
    }

    public function handleGameMessage (evt :MessageReceivedEvent) :void
    {
        if (evt.name == ACTIVATE) {
            if (_module == null) {
                _module = new ServerModule(_ctrl);
            }
            _module.activate();
            _ctrl.getPlayer(evt.senderId).sendMessage(ACKNOWLEDGED, true);

        } else if (evt.name == DEACTIVATE) {
            if (_module != null) {
                _module.deactivate();
                _ctrl.getPlayer(evt.senderId).sendMessage(ACKNOWLEDGED, false);
            }
        }
    }

    protected var _ctrl :AVRServerGameControl;
    protected var _module :ServerModule;
}

}
