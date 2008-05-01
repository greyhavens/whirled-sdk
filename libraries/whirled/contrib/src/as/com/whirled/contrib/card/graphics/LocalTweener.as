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

package com.whirled.contrib.card.graphics {

import caurina.transitions.Tweener;

/** Wrapper for caurina.transitions.Tweener. */
public class LocalTweener
{
    public static function addTween (
        p_arg1 :Object = null, 
        p_arg2:Object = null) :Boolean
    {
        return Tweener.addTween(p_arg1, p_arg2);
    }

    public static function removeTweens (
        p_scope :Object, ...args):Boolean
    {
        switch (args.length) {
        case 0:
            return Tweener.removeTweens(p_scope);
        case 1:
            return Tweener.removeTweens(p_scope, args[0]);
        case 2:
            return Tweener.removeTweens(p_scope, args[0], args[1]);
        case 3:
            return Tweener.removeTweens(p_scope, args[0], args[1], args[2]);
        case 4:
            return Tweener.removeTweens(p_scope, args[0], args[1], args[2], 
                args[3]);
        case 5:
            return Tweener.removeTweens(p_scope, args[0], args[1], args[2], 
                args[3], args[4]);
        case 6:
            return Tweener.removeTweens(p_scope, args[0], args[1], args[2], 
                args[3], args[4], args[5]);
        case 7:
            return Tweener.removeTweens(p_scope, args[0], args[1], args[2], 
                args[3], args[4], args[5], args[6]);
        case 8:
            return Tweener.removeTweens(p_scope, args[0], args[1], args[2], 
                args[3], args[4], args[5], args[6], args[7]);
        case 9:
            return Tweener.removeTweens(p_scope, args[0], args[1], args[2], 
                args[3], args[4], args[5], args[6], args[7], args[8]);
        case 10:
            return Tweener.removeTweens(p_scope, args[0], args[1], args[2], 
                args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
        default:
            throw new Error("Need more argument cases");
        }
    }

    public static function isTweening (p_scope :Object) :Boolean
    {
        return Tweener.isTweening(p_scope);
    }
}

}

