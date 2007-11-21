//
// $Id$

package com.whirled.util {
    
import flash.events.Event;
import flash.events.ErrorEvent;

import com.whirled.DataPack;

/**
 * Loader utility for loading item and level packs as data packs.
 */
public class DataPackLoader
{
    /**
     * This constructor takes a list of pack definitions, and two callback functions.
     * Pack definitions should be as a list of objects, in the format produced by
     * {@link WhirledGameControl.getItemPacks} or {@link WhirledGameControl.getLevelPacks}.
     *
     * The loader will extract the URLs of each content pack, and start loading them as data packs.
     * Every time a data pack is finished processing, if the <i>loaded</i> callback is specified,
     * it will be called, passing it the newly loaded pack. Finally, after all packs have been
     * processed, if the <i>done</i> callback is specified, it will be called with an array of all
     * DataPack instances. 
     *
     *  @param definitions Array of content pack definitions.
     *  @param loaded Optional function of type: <pre>function (pack :DataPack) :void {}</pre>,
     *    called once for each loaded data pack.
     *  @param done Optional function of type: <pre>function (packs :Array) :void {}</pre>,
     *    called after all packs were processed, with a list of all DataPack objects.
     */
    public function DataPackLoader (
        definitions :Array, loaded :Function = null, done :Function = null)
    {
        _loadedCallback = loaded;
        _doneCallback = done;

        // make data packs, and wait for them to load
        _packs = definitions.map(function (def :Object, i :*, a :*) :DataPack {
                var pack :DataPack = new DataPack(def.mediaURL);
                pack.addEventListener(Event.COMPLETE, packProcessed);
                pack.addEventListener(ErrorEvent.ERROR, packProcessed);
                return pack;
            });
    }

    /** Returns the list of DataPack instances being loaded. */
    public function get packs () :Array // of DataPack
    {
        return _packs;
    }
    
    /** Stops loading any pending data packs. Should be called during shutdown. */
    public function close () :void
    {
        _packs.forEach(function (pack :DataPack, i :*, a :*) :void {
                pack.close();
            });
    }
    
    /** Remove loader subscriptions, increment count, maybe inform the user. */
    protected function packProcessed (event :Event) :void
    {
        var pack :DataPack = event.target as DataPack;

        pack.removeEventListener(Event.COMPLETE, packProcessed);
        pack.removeEventListener(ErrorEvent.ERROR, packProcessed);

        trace("GOT: " + event);
        
        if (_loadedCallback != null) {
            _loadedCallback((event is ErrorEvent) ? null : pack);
        }
        
        _processedCount++;
        if (_processedCount == _packs.length && _doneCallback != null) {
            _doneCallback(_packs);
        }
    }        

    /** Array of data packs being loaded. */
    protected var _packs :Array; // of DataPack

    /** How many packs did we hear back from? */
    protected var _processedCount :int;
    
    /** Callback that will receive the results of loading a single pack. */
    protected var _loadedCallback :Function;

    /** Callback that will be called once all packs have been processed. */
    protected var _doneCallback :Function;
}

}
