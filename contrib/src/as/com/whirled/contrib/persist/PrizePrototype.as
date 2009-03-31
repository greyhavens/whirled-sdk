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

package com.whirled.contrib.persist {

public class PrizePrototype extends PropertyPrototype
{
    /**
     * Currently the only supported prizeType is PropertyType.TROPHY_PRIZE, but there could be
     * prize types in the future that can be awarded multiple times, or cookie protected instead
     * of trophy protected.
     */
    public function PrizePrototype (name :String, prizeType :PropertyType, playerId :int = 0)
    {
        super(name, playerId);

        switch (prizeType) {
        case PropertyType.TROPHY_PRIZE:
            // these types are prize related, and acceptable
            break;

        default:
            throw new ArgumentError("prizeType is not prize related! [" + prizeType + "]");
        }

        _prizeType = prizeType;
    }

    override public function get type () :PropertyType
    {
        return _prizeType;
    }

    protected var _prizeType :PropertyType;
}
}
