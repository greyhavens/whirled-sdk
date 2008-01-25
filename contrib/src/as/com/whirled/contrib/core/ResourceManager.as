package com.whirled.contrib.core {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

public class ResourceManager extends EventDispatcher
{
    public static function get instance () :ResourceManager
    {
        if (null == g_instance) {
            new ResourceManager();
        }

        return g_instance;
    }

    public function ResourceManager ()
    {
        Assert.isNull(g_instance);
        g_instance = this;
    }
    
    public function getImage (resourceName :String) :BitmapData
    {
        var bitmap :Bitmap = (this.getResource(resourceName) as Bitmap);
        return (null != bitmap ? bitmap.bitmapData : null);
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
    
    public function pendLoadFromURL (resourceName :String, url :String) :void
    {
        this.addPendingLoadInternal(resourceName, new URLResourceLoader(resourceName, url));
    }
    
    public function pendLoadFromBytes (resourceName :String, bytes :ByteArray) :void
    {
        this.addPendingLoadInternal(resourceName, new ByteArrayResourceLoader(resourceName, bytes));
    }
    
    public function pendLoadFromClass (resourceName :String, theClass :Class) :void
    {
        this.addPendingLoadInternal(resourceName, new EmbeddedClassResourceLoader(resourceName, theClass));
    }
    
    public function getResource (resourceName :String) :*
    {
        var loader :ResourceLoader = (_resources.get(resourceName) as ResourceLoader);
        return (null != loader ? loader.resourceData : null);
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
    
    protected function addPendingLoadInternal (resourceName :String, resourceLoader :ResourceLoader) :void
    {
        if (_loading) {
            throw new Error("A load operation is already in progress");
        }
        
        this.unload(resourceName);
        _pendingResources.put(resourceName, resourceLoader);
        
        this.subscribeToResourceLoaderEvents(resourceLoader);
    }
    
    protected function subscribeToResourceLoaderEvents (resourceLoader :ResourceLoader) :void
    {
        resourceLoader.addEventListener(SingleResourceLoadEvent.ERROR, onResourceError);
        resourceLoader.addEventListener(SingleResourceLoadEvent.LOADED, onResourceLoaded);
    }
    
    protected function unsubscribeFromResourceLoaderEvents (resourceLoader :ResourceLoader) :void
    {
        resourceLoader.removeEventListener(SingleResourceLoadEvent.ERROR, onResourceError);
        resourceLoader.removeEventListener(SingleResourceLoadEvent.LOADED, onResourceLoaded);
    }
    
    protected function onResourceLoaded (e :SingleResourceLoadEvent) :void
    {
        var rsrc :ResourceLoader = (e.target as ResourceLoader);
        this.cleanupPendingResource(rsrc.resourceName);
        _resources.put(rsrc.resourceName, rsrc);
        
        if (_pendingResources.size() == 0) {
            _loading = false;
            this.dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.RESOURCES_LOADED));
        }
    }
    
    protected function onResourceError (e :SingleResourceLoadEvent) :void
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

    protected static var g_instance :ResourceManager;
}

}

import com.threerings.util.Assert;
import flash.display.Loader;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.net.URLRequest;
import flash.events.IOErrorEvent;
import flash.utils.ByteArray;
import flash.events.IEventDispatcher;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

class SingleResourceLoadEvent extends Event
{
    public static const LOADED :String = "SingleResource_Loaded";
    public static const ERROR :String = "SingleResource_Error";
    
    public function SingleResourceLoadEvent (type :String)
    {
        super(type, false, false);
    }
}

interface ResourceLoader extends IEventDispatcher
{
    function get resourceName () :String;
    function get isLoaded () :Boolean;
    function get hasError () :Boolean;
    
    function get resourceData () :*;
    
    function load () :void;
    function unload () :void;
}

class ResourceLoaderBase extends EventDispatcher
    implements ResourceLoader
{
    public function ResourceLoaderBase (name :String)
    {
        _name = name;
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
    }

    public function get resourceName () :String
    {
        return _name;
    }

    public function get isLoaded () :Boolean
    {
        return (!_hasError && _isLoaded);
    }

    public function get hasError () :Boolean
    {
        return _hasError;
    }
    
    public function get errorString () :String
    {
        return _errorString;
    }

    public function get resourceData () :*
    {
        return (this.isLoaded ? _loader.content : null);
    }
    
    public function load () :void
    {
        // no-op
    }
    
    public function unload () :void
    {
        try {
            _loader.close();
        } catch (e :Error) {
            // swallow the exception
        }
        
        _loader.unload();
    }

    protected function onInit (e :Event) :void
    {
        _isLoaded = true;
        
        this.dispatchEvent(new SingleResourceLoadEvent(SingleResourceLoadEvent.LOADED));
    }

    protected function onError (e :IOErrorEvent) :void
    {
        _errorString = e.text;
        _hasError = true;
        
        this.dispatchEvent(new SingleResourceLoadEvent(SingleResourceLoadEvent.ERROR));
    }

    protected var _name :String;
    protected var _hasError :Boolean;
    protected var _errorString :String;
    protected var _isLoaded :Boolean;
    protected var _loader :Loader;
}

class URLResourceLoader extends ResourceLoaderBase
{
    public function URLResourceLoader (resourceName :String, url :String)
    {
        super(resourceName);
        _url = url;
    }
    
    override public function load () :void
    {
        _loader.load(new URLRequest(_url));
    }
    
    protected var _url :String;
}

class ByteArrayResourceLoader extends ResourceLoaderBase
{
    public function ByteArrayResourceLoader (resourceName :String, bytes :ByteArray)
    {
        super(resourceName);
        _bytes = bytes;
    }
    
    override public function load () :void
    {
        _loader.loadBytes(_bytes);
    }
    
    protected var _bytes :ByteArray;
}

class EmbeddedClassResourceLoader extends ByteArrayResourceLoader
{
    public function EmbeddedClassResourceLoader (resourceName :String, theClass :Class)
    {
        super(resourceName, ByteArray(new theClass()));
    }
}