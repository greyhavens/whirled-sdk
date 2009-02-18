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

package com.whirled.contrib.platformer.piece {

import com.threerings.util.ClassUtil;

public class DynamicFactory
{
    public function DynamicFactory (xml :XML)
    {
        if (xml != null) {
            for each (var node :XML in xml.children()) {
                for each (var ddef :XML in node.dynamicdef) {
                    _dynamicMap[ddef.@label.toString()] = ddef;
                }
            }
        }
    }

    public function loadDynamic (xml :XML) :Dynamic
    {
        var ddef :XML;
        if (xml.hasOwnProperty("@type")) {
            var type :String = xml.@type;
            if (type != null && type != "") {
                ddef = _dynamicMap[type];
            }
        }
        if (ddef == null) {
            for each (var node :XML in _dynamicMap) {
                if (node.@cname != xml.@cname) {
                    continue;
                }
                ddef = node;
                for each (var cxml :XML in node.elements("const")) {
                    if (!xml.hasOwnProperty("@" + cxml.@id) || xml["@" + cxml.@id] != cxml.@value) {
                        ddef = null;
                        break;
                    }
                }
                if (ddef != null) {
                    break;
                }
            }
        }
        if (ddef != null) {
            xml.@cname = ddef.@cname;
            xml.@type = ddef.@label;
            for each (cxml in ddef.elements("const")) {
                xml["@" + cxml.@id] = cxml.@value;
            }
        }
        var dclass :Class = ClassUtil.getClassByName(xml.@cname);
        if (dclass != null) {
            return new dclass(xml);
        }
        return null;
    }

    protected var _dynamicMap :Object = new Object();
}
}
