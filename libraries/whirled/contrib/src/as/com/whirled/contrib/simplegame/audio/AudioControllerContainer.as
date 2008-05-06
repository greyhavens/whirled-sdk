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

public class AudioControllerContainer extends AudioControllerBase
{
    public function AudioControllerContainer (parentControls :AudioControllerContainer = null)
    {
        super(parentControls);
    }

    internal function attachChild (child :AudioController) :void
    {
        _children.push(child);
    }

    override public function update (dt :Number, parentState :AudioControllerState) :void
    {
        super.update(dt, parentState);

        // update children
        for (var i :int = 0; i < _children.length; ++i) {
            var childController :AudioController = _children[i];
            childController.update(dt, _globalState);
            if (childController.needsCleanup) {
                // @TODO - use a linked list?
                _children.splice(i--, 1);
            }
        }
    }

    override public function stop () :void
    {
        for each (var child :AudioControllerBase in _children) {
            child.stop();
        }
    }

    override public function get needsCleanup () :Boolean
    {
        return (_children.length == 0 && super.needsCleanup);
    }

    protected var _children :Array = [];
}

}
