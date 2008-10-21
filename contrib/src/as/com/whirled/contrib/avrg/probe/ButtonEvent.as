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

import flash.events.Event;

/**
 * Sent when a click occurs in a <code>Button</code>. Invokes a named action in the listener.
 * @see com.whirled.contrib.avrg.probe.Button
 */
public class ButtonEvent extends Event
{
    /** Event type for a button click. */
    public static const CLICK :String = "button.click";

    /**
     * Constructs a new button event.
     */
    public function ButtonEvent (type :String, action :String)
    {
        super(type);
        _action = action;
    }

    /**
     * The action being invoked by this event.
     */
    public function get action () :String
    {
        return _action;
    }

    /** @inheritDoc */
    // from Event
    override public function toString () :String
    {
        return formatToString("ButtonClickEvent", "type", "bubbles", 
            "cancelable", "action");
    }

    protected var _action :String;
}

}
