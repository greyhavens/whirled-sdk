//
// $Id$

package com.whirled.contrib.simplegame.util {

public class Loadable
{
    public function load (onLoaded :Function = null, onLoadErr :Function = null) :void
    {
        if (_loaded && onLoaded != null) {
            onLoaded();

        } else if (!_loaded) {
            if (onLoaded != null) {
                _onLoadedCallbacks.push(onLoaded);
            }
            if (onLoadErr != null) {
                _onLoadErrCallbacks.push(onLoadErr);
            }

            if (!_loading) {
                _loading = true;
                doLoad();
            }
        }
    }

    public function unload () :void
    {
        if (_loading) {
            onLoadCanceled();
        }

        _loaded = false;
        _loading = false;
        _onLoadedCallbacks = [];
        _onLoadErrCallbacks = [];

        doUnload();
    }

    public function get isLoaded () :Boolean
    {
        return _loaded;
    }

    protected function onLoaded () :void
    {
        var callbacks :Array = _onLoadedCallbacks;

        _onLoadedCallbacks = [];
        _onLoadErrCallbacks = [];
        _loaded = true;
        _loading = false;

        for each (var callback :Function in callbacks) {
            callback();
        }
    }

    protected function onLoadErr (err :String) :void
    {
        var callbacks :Array = _onLoadErrCallbacks;
        unload();
        for each (var callback :Function in callbacks) {
            callback(err);
        }
    }

    /**
     * Subclasses may override this to perform logic when an in-progress load is canceled.
     */
    protected function onLoadCanceled () :void
    {
    }

    /**
     * Subclasses must override this to perform the load.
     * If the load is successful, this function should call onLoaded, otherwise it should
     * call unLoadErr.
     */
    protected function doLoad () :void
    {
        throw new Error("abstract");
    }

    /**
     * Subclasses must override this to perform the unload.
     */
    protected function doUnload () :void
    {
        throw new Error("unloadNow");
    }

    protected var _onLoadedCallbacks :Array = [];
    protected var _onLoadErrCallbacks :Array = [];
    protected var _loading :Boolean;
    protected var _loaded :Boolean;
}

}
