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
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.util.Loadable;

public class ResourceSet
    implements Loadable
{
    public function ResourceSet (rm :ResourceManager)
    {
        _rm = rm;
    }

    public function queueResourceLoad (resourceType :String, resourceName: String, loadParams :*)
        :void
    {
        if (_loading || _loaded) {
            throw new Error("Can't queue new resources while a ResourceSet is loading or loaded");
        }

        // check for existing resource with the same name
        if (resourceExists(resourceName)) {
            throw new Error("A resource named '" + resourceName + "' already exists");
        }

        var rsrc :Resource = _rm.createResource(resourceType, resourceName, loadParams);
        if (null == rsrc) {
            throw new Error("Unrecognized Resource type '" + resourceType + "'");
        }

        _resources.put(resourceName, rsrc);
    }

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
                loadNow();
            }
        }
    }

    public function unload () :void
    {
        _rm.setResourceSetLoading(this, false);

        for each (var rsrc :Resource in _resources.values()) {
            rsrc.unload();
        }

        _loaded = false;
        _loading = false;
        _loadedResources = [];
        _onLoadedCallbacks = [];
        _onLoadErrCallbacks = [];
    }

    public function get isLoaded () :Boolean
    {
        return _loaded;
    }

    protected function loadNow () :void
    {
        _loading = true;
        _rm.setResourceSetLoading(this, true);
        for each (var rsrc :Resource in _resources.values()) {
            rsrc.load(
                function (loadedRsrc :Resource) :void {
                    onSingleResourceLoaded(loadedRsrc);
                },
                function (errorRsrc :Resource, err :String) :void {
                    onSingleResourceError(errorRsrc, err);
                });

            // don't continue if the load operation has been canceled/errored
            if (!_loading) {
                break;
            }
        }
    }

    protected function onSingleResourceLoaded (rsrc :Resource) :void
    {
        _loadedResources.push(rsrc);

        // Did we finish loading?
        if (_loadedResources.length == _resources.size()) {
            _loading = false;
            _rm.setResourceSetLoading(this, false);

            // add resources to the ResourceManager
            try {
                _rm.addResources(_loadedResources);
            } catch (e :Error) {
                onError(e.message);
                return;
            }

            var callbacks :Array = _onLoadedCallbacks;

            _onLoadedCallbacks = [];
            _onLoadErrCallbacks = [];
            _loadedResources = [];
            _loaded = true;
            _loading = false;

            for each (var callback :Function in callbacks) {
                callback();
            }
        }
    }

    protected function onSingleResourceError (rsrc :Resource, err :String) :void
    {
        onError(err);
    }

    protected function onError (err :String) :void
    {
        var callbacks :Array = _onLoadErrCallbacks;

        log.warning("Resource load error: " + err);
        unload();

        for each (var callback :Function in callbacks) {
            callback(err);
        }
    }

    protected function resourceExists (name :String) :Boolean
    {
        return (_resources.containsKey(name));
    }

    protected var _rm :ResourceManager;

    protected var _resources :HashMap = new HashMap(); // Map<name, Resource>
    protected var _loadedResources :Array = []; // Array<Resource>

    protected var _onLoadedCallbacks :Array = [];
    protected var _onLoadErrCallbacks :Array = [];
    protected var _loading :Boolean;
    protected var _loaded :Boolean;

    protected static const log :Log = Log.getLog(ResourceSet);
}

}
