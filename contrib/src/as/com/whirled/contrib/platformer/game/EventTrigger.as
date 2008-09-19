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

import flash.system.ApplicationDomain;

public class EventTrigger
{
    public static function createEventTrigger (gctrl :GameController, xml :XML) :EventTrigger
    {
        var cname :String = xml.@cname;
        if (cname == null || !ApplicationDomain.currentDomain.hasDefinition(cname)) {
            trace("could not find class for event trigger " + cname);
            return null;
        }
        var triggerClass :Class = ApplicationDomain.currentDomain.getDefinition(cname) as Class;
        return new triggerClass(gctrl, xml) as EventTrigger;
    }

    public function EventTrigger (gctrl :GameController)
    {
        _gctrl = gctrl;
    }

    public function hasTriggered () :Boolean
    {
        return _triggered;
    }

    public function checkTriggered () :Boolean
    {
        return false;
    }

    protected var _gctrl :GameController;
    protected var _triggered :Boolean;
}
}
