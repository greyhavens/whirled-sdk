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

package com.whirled.contrib.simplegame.resource {
    
import com.threerings.util.HashMap;
    
public class ResourceLoaderRegistry
{
    public static function get instance () :ResourceLoaderRegistry
    {
        return g_instance;
    }
    
    public function ResourceLoaderRegistry ()
    {
        if (null != g_instance) {
            throw new Error("ResourceLoaderRegistry singleton already instantiated");
        }
        
        g_instance = this;
    }
    
    public function registerLoaderClass (resourceType :String, loaderClass :Class) :void
    {
        _loaderClasses.put(resourceType, loaderClass);
    }
    
    public function createLoader (resourceType :String, resourceName :String, loadParams :*) :ResourceLoader
    {
        var loaderClass :Class = _loaderClasses.get(resourceType);
        if (null != loaderClass) {
            return (new loaderClass(resourceName, loadParams) as ResourceLoader);
        }

        return null;
    }
    
    protected var _loaderClasses :HashMap = new HashMap();
    protected static var g_instance :ResourceLoaderRegistry;

}

}
