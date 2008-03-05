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
