package com.whirled.contrib.core.resource {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;

import flash.events.EventDispatcher;

public class ResourceManager extends EventDispatcher
{
    public function pendResourceLoad (resourceType :String, resourceName: String, loadParams :*) :void
    {
        if (_loading) {
            throw new Error("A load operation is already in progress");
        }
        
        var factory :ResourceFactory = ResourceFactoryRegistry.instance.getFactory(resourceType);
        if (null == factory) {
            throw new Error("missing factory for '" + resourceType + "' resource type");
        }
        
        // check for existing resource with the same name
        if (null != _resources.get(resourceName) || null != _pendingResources.get(resourceName)) {
            throw new Error("A resource named '" + resourceName + "' is already loaded");
        }
        
        var loader :ResourceLoader = factory.createResourceLoader(resourceName, loadParams);
        _pendingResources.put(resourceName, loader);
        this.subscribeToResourceLoaderEvents(loader);
    }
    
    public function load () :void
    {
        if (_loading) {
            throw new Error("A load operation is already in progress");
        }
        
        for each (var rsrc :ResourceLoader in _pendingResources.values()) {
            rsrc.load();
        }
        
        _loading = true;
    }
    
    public function cancelLoad () :void
    {
        if (!_loading) {
            throw new Error("There's no load operation to cancel");
        }
        
        for each (var rsrc :ResourceLoader in _pendingResources.values()) {
            this.unsubscribeFromResourceLoaderEvents(rsrc);
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
    
    protected function subscribeToResourceLoaderEvents (resourceLoader :ResourceLoader) :void
    {
        resourceLoader.addEventListener(ResourceLoadEvent.ERROR, onSingleResourceError);
        resourceLoader.addEventListener(ResourceLoadEvent.LOADED, onSingleResourceLoaded);
    }
    
    protected function unsubscribeFromResourceLoaderEvents (resourceLoader :ResourceLoader) :void
    {
        resourceLoader.removeEventListener(ResourceLoadEvent.ERROR, onSingleResourceError);
        resourceLoader.removeEventListener(ResourceLoadEvent.LOADED, onSingleResourceLoaded);
    }
    
    protected function onSingleResourceLoaded (e :ResourceLoadEvent) :void
    {
        var rsrc :ResourceLoader = (e.target as ResourceLoader);
        this.cleanupPendingResource(rsrc.resourceName);
        
        _resources.put(rsrc.resourceName, rsrc);
        
        if (_pendingResources.size() == 0) {
            _loading = false;
            this.dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.LOADED));
        }
    }
    
    protected function onSingleResourceError (e :ResourceLoadEvent) :void
    {
        var rsrc :ResourceLoader = (e.target as ResourceLoader);
        this.cleanupPendingResource(rsrc.resourceName);
        
        // upon error, cancel all pending loads
        this.cancelLoad();
        
        this.dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.ERROR));
    }
    
    protected function cleanupPendingResource (resourceName :String) :ResourceLoader
    {
        var rsrc :ResourceLoader = _pendingResources.remove(resourceName);
        if (null != rsrc) {
            this.unsubscribeFromResourceLoaderEvents(rsrc);
        }
        
        return rsrc;
    }
    
    protected var _loading :Boolean;

    protected var _resources :HashMap = new HashMap();
    protected var _pendingResources :HashMap = new HashMap();
}

}