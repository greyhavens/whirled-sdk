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

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import com.threerings.util.Log;

public class ResourceManager
{
    public function shutdown () :void
    {
        cancelLoad();
        unloadAll();
    }

    public function registerResourceType (resourceType :String, theClass :Class) :void
    {
        _resourceClasses.put(resourceType, theClass);
    }

    public function queueResourceLoad (resourceType :String, resourceName: String, loadParams :*)
        :void
    {
        // check for existing resource with the same name
        if (resourceExists(resourceName)) {
            throw new Error("A resource named '" + resourceName + "' already exists");
        }

        var rsrc :Resource = createResource(resourceType, resourceName, loadParams);
        if (null == rsrc) {
            throw new Error("No ResourceLoader for '" + resourceType + "' resource type");
        }

        if (_pendingResources == null) {
            _pendingResources = new ResourceSet();
        }

        _pendingResources.pendingResources.put(resourceName, rsrc);
    }

    public function loadQueuedResources (loadCompleteCallback :Function = null,
        loadErrorCallback :Function = null) :void
    {
        if (_pendingResources == null) {
            throw new Error("No resources queued for loading");
        }

        _pendingResources.completeCallback = loadCompleteCallback;
        _pendingResources.errorCallback = loadErrorCallback;

        var rsrcSet :ResourceSet = _pendingResources;
        rsrcSet.loading = true;
        _loadingResources.push(rsrcSet);
        _pendingResources = null;

        for each (var rsrc :Resource in rsrcSet.pendingResources.values()) {
            rsrc.load(
                function (loadedRsrc :Resource) :void {
                    onSingleResourceLoaded(loadedRsrc, rsrcSet);
                },
                function (errorRsrc :Resource, err :String) :void {
                    onSingleResourceError(errorRsrc, err, rsrcSet);
                });

            // don't continue if the load operation has been canceled/errored
            if (!rsrcSet.loading) {
                break;
            }
        }
    }

    public function cancelLoad () :void
    {
        var rsrc :Resource;
        for each (var rsrcSet :ResourceSet in _loadingResources) {
            rsrcSet.cancelLoad();
        }

        _loadingResources = [];

        _pendingResources = null;
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
    }

    public function unloadAll () :void
    {
        for each (var rsrc :Resource in _resources.values()) {
            rsrc.unload();
        }

        _resources = new HashMap();
    }

    public function isResourceLoaded (name :String) :Boolean
    {
        return (null != getResource(name));
    }

    public function get isLoading () :Boolean
    {
        return _loadingResources.length > 0;
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

    protected function onSingleResourceLoaded (rsrc :Resource, rsrcSet :ResourceSet) :void
    {
        var removedObj :Resource = rsrcSet.pendingResources.remove(rsrc.resourceName);
        Assert.isTrue(removedObj == rsrc);
        rsrcSet.loadedResources.put(rsrc.resourceName, rsrc);

        // Did we finish loading?
        if (rsrcSet.pendingResources.size() == 0) {
            rsrcSet.loading = false;
            ArrayUtil.removeFirst(_loadingResources, rsrcSet);

            // Move all resources from the ResourceSet into our _resources map
            for each (var loadedRsrc :Resource in rsrcSet.loadedResources.values()) {
                _resources.put(loadedRsrc.resourceName, loadedRsrc);
            }

            if (rsrcSet.completeCallback != null) {
                rsrcSet.completeCallback();
            }
        }
    }

    protected function onSingleResourceError (rsrc :Resource, err :String, rsrcSet :ResourceSet) :void
    {
        log.warning("Resource load error: " + err);

        // upon error, cancel all pending loads in this set
        rsrcSet.cancelLoad();
        ArrayUtil.removeFirst(_loadingResources, rsrcSet);

        if (rsrcSet.errorCallback != null) {
            rsrcSet.errorCallback(err);
        }
    }

    protected function resourceExists (name :String) :Boolean
    {
        // Have we loaded, are we loading, or are we about to load a resource with
        // the given name?
        if (_resources.containsKey(name)) {
            return true;
        } else if (_pendingResources != null && _pendingResources.resourceExists(name)) {
            return true;
        } else {
            for each (var loadingSet :ResourceSet in _loadingResources) {
                if (loadingSet.resourceExists(name)) {
                    return true;
                }
            }
        }

        return false;
    }

    protected var _resources :HashMap = new HashMap(); // Map<name, resource>
    protected var _pendingResources :ResourceSet;
    protected var _loadingResources :Array = [];

    protected var _resourceClasses :HashMap = new HashMap();

    protected static var log :Log = Log.getLog(ResourceManager);
}

}

import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.resource.Resource;

class ResourceSet
{
    public var pendingResources :HashMap = new HashMap(); // Map<name, resource>
    public var loadedResources :HashMap = new HashMap(); // Map<name, resource>
    public var completeCallback :Function;
    public var errorCallback :Function;
    public var loading :Boolean;

    public function cancelLoad () :void
    {
        if (loading) {
            var rsrc :Resource;
            for each (rsrc in pendingResources.values()) {
                rsrc.unload();
            }
            for each (rsrc in loadedResources.values()) {
                rsrc.unload();
            }

            loading = false;
        }
    }

    public function resourceExists (name :String) :Boolean
    {
        return (pendingResources.containsKey(name) || loadedResources.containsKey(name));
    }
}
