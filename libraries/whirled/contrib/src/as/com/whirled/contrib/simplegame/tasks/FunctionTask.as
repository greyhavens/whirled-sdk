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

package com.whirled.contrib.simplegame.tasks {

import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.SimObject;

public class FunctionTask
    implements ObjectTask
{
    public function FunctionTask (fn :Function)
    {
        if (null == fn || fn.length > 1) {
            throw new ArgumentError("fn must be non-null, and must accept either 0 or 1 arguments");
        }

        _fn = fn;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        if (_fn.length == 0) {
            _fn();
        } else {
            _fn(obj);
        }

        return true;
    }

    public function clone () :ObjectTask
    {
        return new FunctionTask(_fn);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _fn :Function;
}

}
