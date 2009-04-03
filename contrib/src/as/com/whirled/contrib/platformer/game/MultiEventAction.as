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

public class MultiEventAction extends EventAction
{
    public function MultiEventAction (gctrl :GameController, xml :XML)
    {
        super(gctrl, xml);
        _actions = new Array();
        for each (var action :XML in xml.child("action")) {
            _actions.push(EventAction.createEventAction(gctrl, action));
        }
    }

    override public function run () :void
    {
        for each (var action :EventAction in _actions) {
            if (action != null) {
                action.run();
            }
        }
    }

    override public function needServer () :Boolean
    {
        for each (var action :EventAction in _actions) {
            if (action != null && action.needServer()) {
                return true;
            }
        }
        return false;
    }

    protected var _actions :Array;
}
}
