package com.whirled.contrib.core {

import com.threerings.util.Assert;
import com.threerings.util.HashMap;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.utils.ByteArray;

public class ResourceManager
    implements Updatable
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
    
    public function getImage (resourceName :String) :Bitmap
    {
        var bitmap :Bitmap = (this.getResource(resourceName) as Bitmap);
        return (null != bitmap ? new Bitmap(bitmap.bitmapData) : null);
    }
    
    public function loadFromDisk (resourceName :String, filename :String) :void
    {
        _pendingResources.put(resourceName, new FileResourceLoader(resourceName, filename));
    }
    
    public function loadFromBytes (resourceName :String, bytes :ByteArray) :void
    {
        _pendingResources.put(resourceName, new ByteArrayResourceLoader(resourceName, bytes));
    }
    
    public function loadFromClass (resourceName :String, theClass :Class) :void
    {
        _pendingResources.put(resourceName, new EmbeddedClassResourceLoader(resourceName, theClass));
    }
    
    public function getResource (resourceName :String) :*
    {
        var loader :ResourceLoader = (_resources.get(resourceName) as ResourceLoader);
        return (null != loader ? loader.resourceData : null);
    }

    public function unload (name :String) :void
    {
        _resources.remove(name);
        _pendingResources.remove(name);
    }

    public function isLoaded (name :String) :Boolean
    {
        return (null != this.getResource(name));
    }

    public function get hasPendingResources () :Boolean
    {
        return !(_pendingResources.isEmpty());
    }

    // from Updatable
    public function update (dt :Number) :void
    {
        if (!hasPendingResources) {
            return;
        }

        var pending :Array = _pendingResources.values();
        for each (var resource :ResourceLoader in pending) {
            if (resource.hasError) {
                // resource loaders report their own errors, so we don't need to do so here.
                _pendingResources.remove(resource.resourceName);
            } else if (resource.isLoaded) {
                _pendingResources.remove(resource.resourceName);
                _resources.put(resource.resourceName, resource);
            }
        }
    }

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

interface ResourceLoader
{
    function get resourceName () :String;
    function get isLoaded () :Boolean;
    function get hasError () :Boolean;
    
    function get resourceData () :*;
}

class ResourceLoaderBase
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

    public function get resourceData () :*
    {
        return (this.isLoaded ? _loader.content : null);
    }

    protected function onInit (e :Event) :void
    {
        _isLoaded = true;
    }

    protected function onError (e :IOErrorEvent) :void
    {
        trace("Failed to load resource '" + _name + "': " + e.text);
        _hasError = true;
    }

    protected var _name :String;
    protected var _hasError :Boolean;
    protected var _isLoaded :Boolean;
    protected var _loader :Loader;
}

class FileResourceLoader extends ResourceLoaderBase
{
    public function FileResourceLoader (resourceName :String, filename :String)
    {
        super(resourceName);
        _loader.load(new URLRequest(filename));
    }
}

class ByteArrayResourceLoader extends ResourceLoaderBase
{
    public function ByteArrayResourceLoader (resourceName :String, bytes :ByteArray)
    {
        super(resourceName);
        _loader.loadBytes(bytes);
    }
}

class EmbeddedClassResourceLoader extends ResourceLoaderBase
{
    public function EmbeddedClassResourceLoader (resourceName :String, theClass :Class)
    {
        super(resourceName);
        _loader.loadBytes(ByteArray(new theClass()));
    }
}