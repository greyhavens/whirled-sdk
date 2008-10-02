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

public class MultiEventTrigger extends EventTrigger
{
    public function MultiEventTrigger (gctrl :GameController, xml :XML)
    {
        super(gctrl, xml);
        _triggers = new Array();
        for each (var trigger :XML in xml.child("trigger")) {
            _triggers.push(EventTrigger.createEventTrigger(gctrl, trigger));
        }
    }

    override protected function testTriggered () :Boolean
    {
        var ret :Boolean = true;
        for each (var trigger :EventTrigger in _triggers) {
            if (!trigger.checkTriggered()) {
                ret = false;
            }
        }
        return ret;
    }

    protected var _triggers :Array;
}
}
