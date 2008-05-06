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

package com.whirled.contrib.simplegame.audio {

public interface AudioController
{
    function retain () :void;
    function release () :void;
    function get needsCleanup () :Boolean;

    function volume (val :Number) :AudioController;
    function volumeTo (targetVal :Number, time :Number) :AudioController;
    function fadeOut (time :Number) :AudioController;
    function fadeIn (time :Number) :AudioController;
    function pan (val :Number) :AudioController;
    function panTo (targetVal :Number, time :Number) :AudioController;
    function pause () :AudioController;
    function pauseAfter (time :Number) :AudioController;
    function resume () :AudioController;
    function resumeAfter (time :Number) :AudioController;
    function mute () :AudioController;
    function muteAfter (time :Number) :AudioController;

    function stop () :void;

    function update (dt :Number, parentVolume :Number, parentPan :Number, parentPaused :Boolean, parentMuted :Boolean) :void;
}

}
