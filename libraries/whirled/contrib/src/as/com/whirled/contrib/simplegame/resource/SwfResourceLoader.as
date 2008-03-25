package com.whirled.contrib.simplegame.resource {

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;

public class SwfResourceLoader extends EventDispatcher
    implements ResourceLoader
{
    public function SwfResourceLoader (resourceName :String, loadParams :Object)
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

    public function get displayRoot () :DisplayObject
    {
        return _loader.content;
    }
    
    public function getSymbol (name :String) :Object
    {
        try {
            return _loader.contentLoaderInfo.applicationDomain.getDefinition(name);
        } catch (e :Error) {
            // swallow the exception and return null
        }
        
        return null;
    }
    
    public function hasSymbol (name :String) :Boolean
    {
        return _loader.contentLoaderInfo.applicationDomain.hasDefinition(name);
    }
    
    public function getFunction (name :String) :Function
    {
        return this.getSymbol(name) as Function;
    }
    
    public function getClass (name :String) :Class
    {
        return this.getSymbol(name) as Class;
    }
    
    public function get errorString () :String
    {
        return _errorString;
    }
    
    public function load () :void
    {
        // parse loadParams
        
        var context :LoaderContext = new LoaderContext();
        if (_loadParams.hasOwnProperty("useSubDomain") && !Boolean(_loadParams["useSubDomain"])) {
            context.applicationDomain = ApplicationDomain.currentDomain;
        } else {
            // default to loading symbols into a subdomain
            context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
        }
        
        if (_loadParams.hasOwnProperty("url")) {
            _loader.load(new URLRequest(_loadParams["url"]), context);
        } else if (_loadParams.hasOwnProperty("bytes")) {
            _loader.loadBytes(_loadParams["bytes"], context);
        } else if (_loadParams.hasOwnProperty("embeddedClass")) {
            _loader.loadBytes(ByteArray(new _loadParams["embeddedClass"]()), context);
        } else {
            _errorString = "SwfResourceLoader: one of 'url', 'bytes', or 'embeddedClass' must specified in loadParams";
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