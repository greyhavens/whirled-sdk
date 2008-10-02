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

import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import com.threerings.util.Log;

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

    public function registerResourceType (resourceType :String, theClass :Class) :void
    {
        _resourceClasses.put(resourceType, theClass);
    }

    protected function createResource (resourceType :String, resourceName :String, loadParams :*)
        :Resource
    {
        var loaderClass :Class = _resourceClasses.get(resourceType);
        if (null != loaderClass) {
            return (new loaderClass(resourceName, loadParams) as Resource);
        }

        return null;
    }

    public function queueResourceLoad (resourceType :String, resourceName: String, loadParams :*)
        :void
    {
        if (_loading) {
            throw new Error("A load operation is already in progress");
        }

        // check for existing resource with the same name
        if (null != _resources.get(resourceName) || null != _pendingResources.get(resourceName)) {
            throw new Error("A resource named '" + resourceName + "' is already loaded");
        }

        var rsrc :Resource = this.createResource(resourceType, resourceName, loadParams);
        if (null == rsrc) {
            throw new Error("No ResourceLoader for '" + resourceType + "' resource type");
        }

        _pendingResources.put(resourceName, rsrc);
    }

    public function loadQueuedResources (loadCompleteCallback :Function = null,
        loadErrorCallback :Function = null) :void
    {
        if (_loading) {
            throw new Error("A load operation is already in progress");
        }

        _completeCallback = loadCompleteCallback;
        _errorCallback = loadErrorCallback;

        _loading = true;

        for each (var rsrc :Resource in _pendingResources.values()) {
            rsrc.load(onSingleResourceLoaded, onSingleResourceError);

            // don't continue if the load operation has been canceled/errored
            if (!_loading) {
                break;
            }
        }
    }

    public function cancelLoad () :void
    {
        if (!_loading) {
            return;
        }

        for each (var rsrc :Resource in _pendingResources.values()) {
            rsrc.unload();
        }

        _pendingResources = new HashMap();
        _loading = false;
    }

    public function getResource (resourceName :String) :Resource
    {
        return (_resources.get(resourceName) as Resource);
    }

    public function unload (name :String) :void
    {
        var rsrc :Resource;

        rsrc = _resources.remove(name);
        if (null != rsrc) {
            rsrc.unload();
        }

        rsrc = _pendingResources.remove(name);
        if (null != rsrc) {
            rsrc.unload();
        }
    }

    public function unloadAll () :void
    {
        for each (var rsrc :Resource in _resources.values()) {
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

    protected function onSingleResourceLoaded (rsrc :Resource) :void
    {
        var removedObj :Resource = _pendingResources.remove(rsrc.resourceName);
        Assert.isTrue(removedObj == rsrc);

        _resources.put(rsrc.resourceName, rsrc);

        if (_pendingResources.size() == 0) {
            _loading = false;
            if (null != _completeCallback) {
                _completeCallback();
            }
        }
    }

    protected function onSingleResourceError (rsrc :Resource, err :String) :void
    {
        log.warning("Resource load error: " + err);

        // upon error, cancel all pending loads
        this.cancelLoad();

        if (null != _errorCallback) {
            _errorCallback(err);
        }
    }

    protected var _loading :Boolean;
    protected var _completeCallback :Function;
    protected var _errorCallback :Function;

    protected var _resources :HashMap = new HashMap();
    protected var _pendingResources :HashMap = new HashMap();

    protected var _resourceClasses :HashMap = new HashMap();

    protected static var g_instance :ResourceManager;

    protected static var log :Log = Log.getLog(ResourceManager);
}

}
