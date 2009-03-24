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

import com.whirled.contrib.platformer.PlatformerContext;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Hover;
import com.whirled.contrib.platformer.net.HoverMessage;

public class HoverController extends RectDynamicController
{
    public function HoverController (h :Hover, controller :GameController)
    {
        super(h, controller);
        _hover = h;
        addCollisionHandlers();
        if (_hover.owner == Dynamic.OWN_SERVER && _hover.amOwner()) {
            _hoverers = new Array();
            PlatformerContext.net.addEventListener(HoverMessage.NAME, hoverMsgReceived);
        }
    }

    override public function shutdown () :void
    {
        super.shutdown();
        PlatformerContext.net.removeEventListener(HoverMessage.NAME, hoverMsgReceived);
    }

    protected function addCollisionHandlers () :void
    {
        addCollisionHandler(new HoverCollisionHandler(this));
    }

    protected function hoverMsgReceived (hoverMsg :HoverMessage) :void
    {
        if (hoverMsg.id == _hover.id) {
            var idx :int = _hoverers.indexOf(hoverMsg.senderId);
            if (hoverMsg.state == HoverMessage.HOVER) {
                if (idx == -1) {
                    _hoverers.push(hoverMsg.senderId);
                }
            } else if (idx != -1) {
                _hoverers.splice(idx, 1);
            }
            _hover.hovered = _hoverers.length == 0;
        }
    }

    protected var _hover :Hover;
    protected var _hoverers :Array;
}
}
