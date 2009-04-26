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
        if (_yardBit != null) {
            Thane.unspawnYard(_yardBit.id);
        }
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
        return "HttpUserCode [url=" + _url + ", className=" + _className + ", yardId=" +
            _yardId + ", class=" + _class + ", instance=" + _instance +
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
            _yardBit = _yardBits.get(_yardId);
            if (_yardBit == null) {
                _yardBit = new YardBit();
                _yardBit.id = "Yard#" + (++ _lastId);
                _yardBit.bridge = new EventDispatcher();

                if (_traceListener != null) {
                    _yardBit.bridge.addEventListener(TraceEvent.TRACE, relayTrace);
                }

                trace("Creating new yard: " + _yardBit.id);
                _yardBit.yard = Thane.spawnYard(
                    _yardBit.id, _loader.data, _yardBit.id + ": ", _yardBit.bridge);

                _yardBits.put(_yardId, _yardBit);
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

    protected function relayTrace (evt :TraceEvent) :void {
        if (evt.trace != null) {
            _traceListener(evt.trace.join(" "));
        }
    }

    protected function yardBitAvailable () :void
    {
        _puddle = new Puddle(_yardBit.yard);
        trace("Created new puddle within yard: " + _yardBit.id);
        _class = _puddle.domain.getClass(_className);
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
    protected var _yardId :String;
    protected var _yardBit :YardBit;
    protected var _puddle :Puddle;
    protected var _class :Class;
    protected var _instance :Object;

    protected static var _lastId :int;
    protected static var _yardBits :HashMap = new HashMap();
}

}

import avmplus.Yard;
import avmplus.Puddle;

import flash.events.EventDispatcher;

class YardBit
{
    public var id :String;
    public var bridge :EventDispatcher;
    public var yard :Yard;
}
