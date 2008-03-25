package com.whirled.contrib.simplegame.resource {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.ByteArray;

public class ImageResourceLoader extends EventDispatcher
    implements ResourceLoader
{
    public function ImageResourceLoader (resourceName :String, loadParams :Object)
    {
        _resourceName = resourceName;
        _loadParams = loadParams;
        
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
    }

    public function get resourceName () :String
    {
        return _resourceName;
    }

    public function get bitmapData () :BitmapData
    {
        return (_loader.content as Bitmap).bitmapData;
    }
    
    public function createBitmap (pixelSnapping :String = "auto", smoothing :Boolean = false) :Bitmap
    {
        return new Bitmap(this.bitmapData, pixelSnapping, smoothing);
    }
    
    public function get errorString () :String
    {
        return _errorString;
    }
    
    public function load () :void
    {
        // parse loadParams
        if (_loadParams.hasOwnProperty("url")) {
            _loader.load(new URLRequest(_loadParams["url"]));
        } else if (_loadParams.hasOwnProperty("bytes")) {
            _loader.loadBytes(_loadParams["bytes"]);
        } else if (_loadParams.hasOwnProperty("embeddedClass")) {
            _loader.loadBytes(ByteArray(new _loadParams["embeddedClass"]()));
        } else {
            _errorString = "ImageResourceLoader: one of 'url', 'bytes', or 'embeddedClass' must specified in loadParams";
            this.dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.ERROR));
        }
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
        this.dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.LOADED));
    }

    protected function onError (e :IOErrorEvent) :void
    {
        _errorString = e.text;
        this.dispatchEvent(new ResourceLoadEvent(ResourceLoadEvent.ERROR));
    }

    protected var _resourceName :String;
    protected var _loadParams :Object;
    protected var _errorString :String;
    protected var _loader :Loader;
}

}
