//
// $Id$

package com.whirled.util {
    
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;

import flash.events.Event;
import flash.events.IOErrorEvent;

import flash.net.URLRequest;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

/**
 * <b>Note</b>: This class is deprecated. It will be removed when a suitable replacement
 * is made.<br>
 *
 * Loader utility for loading item and level packs.
 */
public class ContentPackLoader
{
    /**
     * This constructor takes a list of pack definitions, and two callback functions.
     * Pack definitions should be in the format produced by {@link WhirledGameControl.getItemPacks}
     * or {@link WhirledGameControl.getLevelPacks}.
     *
     * The loader will start loading content packs immediately. Every time a content pack finished
     * processing, the <i>loaded</i> callback will be called, and it will receive either a
     * ContentPack instance for the loaded SWF, or null if the pack failed to load. Finally,
     * after all packs have been processed, the <i>done</i> callback will be called.
     *
     *  @param definitions Array of content pack definitions.
     *  @param loaded Function of type: function (pack :ContentPack) :void {}, called once for each
     *    loaded content pack; the <i>pack</i> variable may be null if the pack failed to load.
     *  @param done Function of type: function () :void {}, called after all packs were processed.
     *  @param useSubDomain Optional boolean flag; if true, it will create a separate child
     *    application domain for the content pack, allowing class redefinition.
     */
    public function ContentPackLoader (
        definitions :Array, loaded :Function, done :Function, useSubDomain :Boolean = false)
    {
        _loadedCallback = loaded;
        _doneCallback = done;

        // make one loader for each content pack definition, and start loading!
        _infos = definitions.map(function (def :Object, i :*, a :*) :LoaderInfo {
                var loader :Loader = new Loader();
                var info :LoaderInfo = loader.contentLoaderInfo;
                info.addEventListener(Event.COMPLETE, loaderProcessed);
                info.addEventListener(IOErrorEvent.IO_ERROR, loaderProcessed);

                var request :URLRequest = new URLRequest(def.mediaURL);
                var context :LoaderContext = new LoaderContext();
                context.applicationDomain = useSubDomain ? 
                  new ApplicationDomain(ApplicationDomain.currentDomain) : 
                  ApplicationDomain.currentDomain;
                loader.load(request, context);

                return info;
            });
    }

    /** Remove loader subscriptions, increment count, maybe inform the user. */
    public function loaderProcessed (event :Event) :void
    {
        var info :LoaderInfo = event.target as LoaderInfo;
        info.removeEventListener(Event.COMPLETE, loaderProcessed);
        info.removeEventListener(IOErrorEvent.IO_ERROR, loaderProcessed);

        _loadedCallback((event is IOErrorEvent) ? null : new ContentPack(info.loader));
        
        _processedLoaderCount++;
        if (_processedLoaderCount == _infos.length) {
            _doneCallback(_infos);
        }
    }        

    /** Array of loader infos, one for each definition. */
    protected var _infos :Array; // of LoaderInfo

    /** How many loaders did we hear back from? */
    protected var _processedLoaderCount :int;
    
    /** Callback that will receive the results of loading a single definitions. */
    protected var _loadedCallback :Function;

    /** Callback that will be called once all definitions have been processed. */
    protected var _doneCallback :Function;
}

}
