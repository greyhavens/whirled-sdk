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

package com.whirled.contrib {

import flash.display.Loader;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;

/**
 * This is a utility class used fetch a class definition from one of several loaders in a simple
 * way.  The loaders can either be flash.display.Loader or com.threerings.util.EmbeddedSwfLoader.
 * 
 * This class is but a poor utility without much for brains.  It assumes that the loaders it is 
 * given have finished loading.  It also assumes that any string it is asked to search for is a 
 * Class.  You are warned!
 *
 * This is deprecated. The way you should do things is: use a MultiLoader.getLoaders() to load
 * your assets and specify an ApplicationDomain in which to load everything.
 * Then you can just load the classes out of that ApplicationDomain.
 * @example
 * <listing version="3.0">
 * var appDom :ApplicationDomain = new ApplicationDomain(null); // create a new top-level appdom
 *
 * var complete :Function = function (result :Object) :void {
 *     // now we can load classes from the appDom:
 *     var someClass :Class = appDom.getDefinition("package.SomeClass") as Class;
 *     // ...
 * };
 *
 * MultiLoader.getLoaders([ RESOURCE1, RESOURCE2, ... ], complete, false, appDom);
 * </listing>
 */
[Deprecated(replacement="com.threerings.util.MultiLoader")]
public class ClassLoader 
{
    public function ClassLoader (... loaders) :void
    {
        for each (var loader :Object in loaders) {
            if (loader is EmbeddedSwfLoader) {
                _embeddeds.push(loader);
            } else if (loader is Loader) {
                _loaders.push(loader);
            } else {
                log.debug("Unknown parameter to ClassLoader constructor [" + loader + "]");
            }
        }
    }

    /**
     * This function will return null if the class is not found, rather than throwing an error
     * somewhere along the way.
     */
    public function getClass (clz :String) :Class
    {
        for each (var embeddedLoader :EmbeddedSwfLoader in _embeddeds) {
            if (embeddedLoader.isSymbol(clz)) {
                return embeddedLoader.getClass(clz);
            }
        }
        for each (var loader :Loader in _loaders) {
            if (loader.contentLoaderInfo.applicationDomain.hasDefinition(clz)) {
                return loader.contentLoaderInfo.applicationDomain.getDefinition(clz) as Class;
            }
        }
        return null;
    }

    protected var _loaders :Array = [];
    protected var _embeddeds :Array = [];

    private static var log :Log = Log.getLog(ClassLoader);
}
}
