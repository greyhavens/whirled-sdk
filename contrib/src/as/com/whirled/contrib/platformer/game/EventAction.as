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

public class EventAction
{
    public static function createEventAction (gctrl :GameController, xml :XML) :EventAction
    {
        var cname :String = xml.@cname;
        if (cname == null || !ApplicationDomain.currentDomain.hasDefinition(cname)) {
            trace("could not find class for event action " + cname);
            return null;
        }
        var triggerClass :Class = ApplicationDomain.currentDomain.getDefinition(cname) as Class;
        return new triggerClass(gctrl, xml) as EventAction;
    }


    public function EventAction (gctrl :GameController)
    {
        _gctrl = gctrl;
    }

    public function run () :void
    {
    }

    protected var _gctrl :GameController;
}
}
