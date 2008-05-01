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

package com.whirled.contrib
{

/**
 * Interface for game modes, handled by the GameModeStack. Game modes are notified when they
 * become activated and deactivated, so that they can adjust themselves accordingly.
 */
public interface GameMode
{
    /**
     * Called when this instance of GameMode is added to the top of the stack.
     */
    function pushed () :void;

    /**
     * Called when this instance of GameMode is removed from the top of the stack.
     */
    function popped () :void;

    /**
     * Called when this instance of GameMode was the top of the stack, but another instance
     * is being pushed on top of it.
     */
    function pushedOnto (mode :GameMode) :void;

    /**
     * Called when another instance is being removed from the top of the stack,
     * making this instance the new top.
     */
    function poppedFrom (mode :GameMode) :void;
}
}
