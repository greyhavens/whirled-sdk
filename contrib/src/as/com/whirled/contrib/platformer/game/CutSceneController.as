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

package com.whirled.contrib.platformer.game {

import com.whirled.net.MessageReceivedEvent;

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.net.CutSceneMessage;
import com.whirled.contrib.platformer.piece.CutScene;

public class CutSceneController extends HoverController
    implements PauseController
{
    public function CutSceneController (cs :CutScene, controller :GameController)
    {
        super(cs, controller);
        _cs = cs;
        var tot :Number = 0;
        for each (var len :Number in _cs.stageChanges) {
            tot += len;
            _stageChanges.push(tot);
        }
        if (_cs.played) {
            _state = END;
        } else {
            PlatformerContext.net.addEventListener(
                    MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        }
    }

    override public function shutdown () :void
    {
        super.shutdown();
        PlatformerContext.net.removeEventListener(
                    MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }

    override public function tick (delta :Number) :void
    {
        super.tick(delta);
        if (_cs.amOwner()) {
            switch (_state) {
            case OFF:
                if (_cs.hovered) {
                    _state = INIT;
                    PlatformerContext.net.sendMessage(CutSceneMessage.create(CutSceneMessage.INIT));
                }
                break;
            case END:
                if (!_cs.played) {
                    PlatformerContext.net.sendMessage(
                            CutSceneMessage.create(CutSceneMessage.CLOSE));
                    PlatformerContext.net.removeEventListener(
                            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
                    _cs.played = true;
                }
            }
        }
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.value is CutSceneMessage) {
            var msg :CutSceneMessage = event.value as CutSceneMessage;
            gotMessage(msg.type, event.senderId);
        }
    }

    protected function gotMessage (type :int, id :int) :void
    {
        if (_state == INIT && type == CutSceneMessage.START) {
            _state = PLAY;
            PlatformerContext.net.sendMessage(CutSceneMessage.create(CutSceneMessage.PLAY));
        } else if (_state == PLAY && type == CutSceneMessage.END) {
            _state = END;
        }
    }

/*
    override protected function addCollisionHandlers () :void
    {
        addCollisionHandler(new CutSceneCollisionHandler(this));
    }
*/

    protected var _cs :CutScene;
    protected var _tick :Number = 0;
    protected var _keyReset :Number = 0;
    protected var _ignoreKeys :Boolean;
    protected var _stageChanges :Array = new Array();
    protected var _state :int;
    protected static const KEY_RESET :Number = 0.3;

    protected static const OFF :int = 0;
    protected static const INIT :int = 1;
    protected static const PLAY :int = 2;
    protected static const END :int = 3;

}
}
