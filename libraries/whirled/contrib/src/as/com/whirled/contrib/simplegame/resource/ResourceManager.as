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

[Event(name="Loaded", type="com.whirled.contrib.simplegame.resource.ResourceLoadEvent")]
[Event(name="Error", type="com.whirled.contrib.simplegame.resource.ResourceLoadEvent")]

public class ResourceManager
{
    public static function get instance () :ResourceManager
    {
        return g_instance;
    }

    public function ResourceManager ()
    {
        if (null != g_instance) {
            throw new Error("ResourceManager instance already exists");
        }

        g_instance = this;
    }

    public function shutdown () :void
    {
        this.unloadAll();
        g_instance = null;
    }

    public function pendResourceLoad (resourceType :String, resourceName: String, loadParams :*) :void
    {
        if (_loading) {
            throw new Error("A load operation is already in progress");
        }

        // check for existing resource with the same name
        if (null != _resources.get(resourceName) || null != _pendingResources.get(resourceName)) {
            throw new Error("A resource named '" + resourceName + "' is already loaded");
        }

        var loader :ResourceLoader = ResourceLoaderRegistry.instance.createLoader(resourceType, resourceName, loadParams);
        if (null == loader) {
            throw new Error("No ResourceLoader for '" + resourceType + "' resource type");
        }

        _pendingResources.put(resourceName, loader);
    }

    public function load (loadCompleteCallback :Function = null, loadErrorCallback :Function = null) :void
    {
        if (_loading) {
            throw new Error("A load operation is already in progress");
        }

        _completeCallback = loadCompleteCallback;
        _errorCallback = loadErrorCallback;

        _loading = true;

        for each (var rsrc :ResourceLoader in _pendingResources.values()) {
            rsrc.load(onSingleResourceLoaded, onSingleResourceError);
        }
    }

    public function cancelLoad () :void
    {
        if (!_loading) {
            return;
        }

        for each (var rsrc :ResourceLoader in _pendingResources.values()) {
            rsrc.unload();
        }

        _pendingResources = new HashMap();
        _loading = false;
    }

    public function getResource (resourceName :String) :ResourceLoader
    {
        return (_resources.get(resourceName) as ResourceLoader);
    }

    public function unload (name :String) :void
    {
        var rsrc :ResourceLoader;

        rsrc = _resources.remove(name);
        if (null != rsrc) {
            rsrc.unload();
        }

        rsrc = this.cleanupPendingResource(name);
        if (null != rsrc) {
            rsrc.unload();
        }
    }

    public function unloadAll () :void
    {
        for each (var rsrc :ResourceLoader in _resources.values()) {
            rsrc.unload();
        }

        _resources = new HashMap();

        this.cancelLoad();
    }

    public function isResourceLoaded (name :String) :Boolean
    {
        return (null != this.getResource(name));
    }

    public function get isLoading () :Boolean
    {
        return _loading;
    }

    protected function onSingleResourceLoaded (rsrc :ResourceLoader) :void
    {
        this.cleanupPendingResource(rsrc.resourceName);

        _resources.put(rsrc.resourceName, rsrc);

        if (_pendingResources.size() == 0) {
            _loading = false;
            if (null != _completeCallback) {
                _completeCallback();
            }
        }
    }

    protected function onSingleResourceError (rsrc :ResourceLoader, err :String) :void
    {
        this.cleanupPendingResource(rsrc.resourceName);

        // upon error, cancel all pending loads
        this.cancelLoad();

        if (null != _errorCallback) {
            _errorCallback(err);
        }
    }

    protected function cleanupPendingResource (resourceName :String) :ResourceLoader
    {
        return _pendingResources.remove(resourceName);
    }

    protected var _loading :Boolean;
    protected var _completeCallback :Function;
    protected var _errorCallback :Function;

    protected var _resources :HashMap = new HashMap();
    protected var _pendingResources :HashMap = new HashMap();

    protected static var g_instance :ResourceManager;
}

}
