package com.whirled.thane {

import avmplus.Domain;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import com.adobe.net.URI;
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

        _bridge = new EventDispatcher();
        if (traceListener != null) {
            _bridge.addEventListener(TraceEvent.TRACE, function (evt :TraceEvent) :void {
                if (evt.trace != null) {
                    traceListener(evt.trace.join(" "));
                }
            });
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
        try {
            _bridge.addEventListener("controlConnect", connectListener);
            _instance = new _class();
            log.info("New server instantiated!");
        }
        finally {
            _bridge = null; // prevent connecting twice
        }
    }

    /** @inheritDoc */
    // from UserCode
    public function release () :void
    {
        log.info("Releasing " + this);
        if (_domain != null) {
            Thane.unspawnDomain(_domain);
        }
        releaseReferences();
    }

    /** @inheritDoc */
    public function outputTrace (str :String, err :Error = null) :void
    {
        Thane.outputToTrace(_domain, str, err);
    }

    /** @inheritDoc */
    // from Object
    public function toString () :String
    {
        return "HttpUserCode [url=" + _url + ", className=" + _className + ", domainId=" +
            _domainId + ", domain=" + _domain + ", class=" + _class + ", instance=" + _instance +
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
            _domainId = "UserCode-" + (++_lastId);
            var consoleTracePrefix :String = _domainId + ": ";
            _domain = Thane.spawnDomain(_domainId, consoleTracePrefix, _bridge);
            _domain.loadBytes(_loader.data);
            _loader = null;
            _class = _domain.getClass(_className);
            success = _class != null;

        } catch (err :Error) {
            log.info("Error loading user code: " + err.getStackTrace());
            outputTrace("Could not instantiate server class", err);

        } finally {

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
    }

    /** Set everything we've used to null. */
    protected function releaseReferences () :void
    {
        _loader = null;
        _bridge = null;
        _domain = null;
        _class = null;
        _instance = null;
    }

    protected var _url :String;
    protected var _className :String;
    protected var _callback :Function;
    protected var _loader :URLLoader;
    protected var _bridge :EventDispatcher;
    protected var _domainId :String;
    protected var _domain :Domain;
    protected var _class :Class;
    protected var _instance :Object;

    protected static var _lastId :int;
}

}
