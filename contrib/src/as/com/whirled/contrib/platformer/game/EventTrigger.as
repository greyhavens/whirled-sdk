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

import com.threerings.util.ClassUtil;

public class EventTrigger
{
    public static function createEventTrigger (gctrl :GameController, xml :XML) :EventTrigger
    {
        var cname :String = xml.@cname;
        var triggerClass :Class;
        if (cname != null) {
            triggerClass = ClassUtil.getClassByName(cname);
        }
        if (cname == null || triggerClass == null) {
            trace("could not find class for event trigger " + cname);
            return null;
        }
        return new triggerClass(gctrl, xml) as EventTrigger;
    }

    public function EventTrigger (gctrl :GameController, xml :XML)
    {
        _gctrl = gctrl;
    }

    public function hasTriggered () :Boolean
    {
        return _triggered;
    }

    public function checkTriggered () :Boolean
    {
        if (hasTriggered()) {
            return true;
        }
        _triggered = testTriggered();
        return hasTriggered();
    }

    protected function testTriggered () :Boolean
    {
        return false;
    }

    protected var _gctrl :GameController;
    protected var _triggered :Boolean;
}
}
