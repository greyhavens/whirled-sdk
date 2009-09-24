//
// $Id$
//
// Narya library - tools for developing networked games
// Copyright (C) 2002-2009 Three Rings Design, Inc., All Rights Reserved
// http://www.threerings.net/code/narya/
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package com.whirled.client {

import flash.utils.Proxy;
import flash.utils.flash_proxy;

use namespace flash_proxy;

/**
 * Routes all requests on the source object to the namespace specified.
 */
public class BackendHelper extends Proxy
{
    public function BackendHelper (
        source :Object, namespace :Namespace, fallback :Object = null)
    {
        _source = source;
        _ns = namespace;
        _fallback = fallback || {};
    }

//    public function hasOwnProperty (name :String) :Boolean
//    {
//        return _source.hasOwnProperty(name);
//    }
//
//    public function isPrototypeOf (theClass :Object) :Boolean
//    {
//        return _source.isPrototypeOf(theClass);
//    }
//
//    public function propertyIsEnumerable (name :String) :Boolean
//    {
//        return _source.propertyIsEnumerable(name);
//    }
//
//    public function setPropertyIsEnumerable (name :String, isEnum :Boolean = true) :void
//    {
//        immutable();
//    }

    // valueOf ?

    override flash_proxy function callProperty (name :*, ... rest) :*
    {
        return Function(flash_proxy::getProperty(name)).apply(null, rest);
    }

    override flash_proxy function deleteProperty (name :*) :Boolean
    {
        return false;
    }

    // omitted: getDescendants

    /**
     * Herein lies the magic.
     */
    override flash_proxy function getProperty (name :*) :*
    {
        var val :* = _source[new QName(_ns, name)];
        if (val === undefined) {
            val = _fallback[name];
        }
        return val;
    }

    override flash_proxy function hasProperty (name :*) :Boolean
    {
        return (undefined !== flash_proxy::getProperty(name));
    }

    // omitted: isAttribute

    override flash_proxy function nextName (index :int) :String
    {
        return null;
    }

    override flash_proxy function nextNameIndex (index :int) :int
    {
        return 0;
    }

    override flash_proxy function nextValue (index :int) :*
    {
        return undefined;
    }

    override flash_proxy function setProperty (name :*, value :*) :void
    {
        throw new Error();
    }

    protected var _source :Object;

    protected var _ns :Namespace;

    protected var _fallback :Object;
}
}
