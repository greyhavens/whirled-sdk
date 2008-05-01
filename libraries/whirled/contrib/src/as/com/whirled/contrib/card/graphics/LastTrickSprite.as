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

import flash.display.Sprite;

/** Graphics for the cards in the last trick. */
public class LastTrickSprite extends Sprite
{
    /** Creates a new last trick sprite */
    public function LastTrickSprite ()
    {
    }

    /** Clear out the cards and reset them.
     *  @param cards the array of CardSprite instances to become the contents of this sprite
     */
    public function setCards (cards :Array) :void
    {
        clear();
        cards.forEach(add);
        
        function add (c :CardSprite, i :int, a :Array) :void {
            addChild(c);
            _cards.push(c);
        }
    }

    /** Clear our the current contents of the last trick. */
    public function clear () :void
    {
        _cards.forEach(remove);
        _cards.splice(0, _cards.length);
        
        function remove (c :CardSprite, i :int, a :Array) :void {
            removeChild(c);
        }
    }

    protected var _cards :Array = new Array();
}

}
