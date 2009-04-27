package com.whirled.thane {

import avmplus.Yard;
import avmplus.Puddle;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import com.adobe.net.URI;

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.whirled.bureau.client.UserCodeLoader;
import com.whirled.bureau.client.UserCode;

/** Thane implementation of <code>UserCode</code>. */
public class HttpUserCode
    implements UserCode
{
    protected static var log :Log = Log.getLog(HttpUserCode);

    /** Creates a new HttpUserCode and automatically starts downloading code.
     *  @param url the location of the code media (abc file)
     *  @param className the name of the class to look for in the library
     *  @param callback the function to call when the class is found 
     *  @param traceListener the function to call to output messages */
    public function HttpUserCode (
        url :String, className :String, callback :Function, traceListener :Function)
    {
        _url = url;
        _className = className;
        _callback = callback;
        _traceListener = traceListener;

        _yardBit = _yardBits.get(url);
        if (_yardBit != null) {
            setTimeout(yardBitAvailable, 0);
            return;
        }

        _loader = new URLLoader();
        _loader.addEventListener(IOErrorEvent.IO_ERROR, handleError);
        _loader.addEventListener(Event.COMPLETE, handleComplete);

        _loader.load(new URLRequest(_url));
    }

    /** @inheritDoc */
    // from UserCode
    public function connect (connectListener :Function) :void
    {
        _yardBit.bridge.addEventListener("controlConnect", connectListener);
        _instance = new _class();
        log.info("New server instantiated!");
    }

    /** @inheritDoc */
    // from UserCode
    public function release () :void
    {
        log.info("Releasing " + this);
// TODO: It's high time we figure out for sure how to nuke a domain.
//        if (_yardBit != null) {
//            Thane.unspawnYard(_yardBit.id);
//        }
        releaseReferences();
    }

    /** @inheritDoc */
    public function outputTrace (str :String, err :Error = null) :void
    {
        Thane.outputToTrace(_yardBit.yard, str, err);
    }

    /** @inheritDoc */
    // from Object
    public function toString () :String
    {
        return "HttpUserCode [url=" + _url + ", className=" + _className + ", yard=" +
            _yardBit + ", class=" + _class + ", instance=" + _instance +
            "]";
    }

    /** Receive some data from teh intarnets. */
    protected function handleError (evt :IOErrorEvent) :void
    {
        log.warning("Error while downloading code", "code", this, "evt", evt);
        _callback(null);
    }

    /** Finished receiving data. */
    protected function handleComplete (evt :Event) :void
    {
        var success :Boolean = false;

        try {
            // check again if the yard was resolved while we were waiting
            _yardBit = _yardBits.get(_url);
            if (_yardBit == null) {
                var id :String = "Yard#" + (++ _lastId);
                var bridge :EventDispatcher = new EventDispatcher();

                trace("Creating new yard: " + id);
                var yard :Yard = Thane.spawnYard(id, _loader.data, id + ": ", bridge);

                _yardBit = new YardBit(id, yard, bridge, _className);
                _yardBits.put(_url, _yardBit);
            }
            yardBitAvailable();

        } catch (err :Error) {
            log.error("Error loading user code: " + err.getStackTrace());
            outputTrace("Could not instantiate server class", err);
            informCaller(false);

        } finally {
            _loader = null;

        }
    }

    protected function yardBitAvailable () :void
    {
        _puddle = new Puddle(_yardBit.yard);

        trace("Created new puddle within yard: " + _yardBit.id);
        _class = _puddle.domain.getClass(_className);

        // map this class to the associated trace listener (yeah this is weird)
        _yardBit.listeners[_class] = _traceListener;
        _traceListener = null;

        informCaller(_class != null);
    }

    protected function informCaller (success :Boolean) :void
    {
        try {
            _callback(success ? this : null);

        } catch (err :Error) {
            log.warning("Error invoking callback: " + err.getStackTrace());
            releaseReferences();
        }

        _callback = null;

        if (!success) {
            release();
        }
    }

    /** Set everything we've used to null. */
    protected function releaseReferences () :void
    {
        if (_class != null && _yardBit != null) {
            delete _yardBit.listeners[_class];
        }

        _loader = null;
        _puddle = null;
        _yardBit = null;
        _class = null;
        _instance = null;
    }

    protected var _url :String;
    protected var _className :String;
    protected var _callback :Function;
    protected var _loader :URLLoader;
    protected var _traceListener :Function;
    protected var _yardBit :YardBit;
    protected var _puddle :Puddle;
    protected var _class :Class;
    protected var _instance :Object;

    protected static var _lastId :int;

    // track yardbits per URL
    protected static var _yardBits :HashMap = new HashMap();
}

}

import avmplus.Yard;
import avmplus.Puddle;

import flash.events.EventDispatcher;

import flash.utils.Dictionary;

class YardBit
{
    public var id :String;
    public var yard :Yard;
    public var bridge :EventDispatcher;
    public var className :String;
    public var listeners :Dictionary = new Dictionary();

    public function YardBit (id :String, yard :Yard, bridge :EventDispatcher, className :String)
    {
        this.id = id;
        this.yard = yard;
        this.bridge = bridge;
        this.className = className;

        bridge.addEventListener(TraceEvent.TRACE, relayTrace);
    }

    public function toString () :String
    {
        return "[Yard id=" + id + "]";
    }

    protected function relayTrace (evt :TraceEvent) :void
    {
        if (evt.trace != null) {
            var cls :Class = evt.domain.getClass(className);
            var fun :Function = listeners[cls];
            if (fun == null) {
                trace("Eek, got a trace I couldn't place: " + evt.trace.join(" "));
                return;
            }
            fun(evt.trace.join(" "));
        }
    }
}
