package com.whirled.thane {

import avmplus.Domain;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import com.adobe.net.URI;
import org.httpclient.HttpClient;
import org.httpclient.http.Get;
import org.httpclient.events.HttpDataEvent;
import org.httpclient.events.HttpErrorEvent;
import org.httpclient.events.HttpStatusEvent;
import com.whirled.bureau.client.UserCodeLoader;
import com.whirled.bureau.client.UserCode;

/** Thane implementation of <code>UserCode</code>. */
public class HttpUserCode
    implements UserCode
{
    /** Creates a new HttpUserCode and automatically starts downloading code.
     *  @param url the location of the code media (abc file)
     *  @param className the name of the class to look for in the library
     *  @param callback the function to call when the class is found */
    public function HttpUserCode (
        url :String,
        className :String,
        callback :Function)
    {
        _url = url;
        _className = className;
        _callback = callback;

        // TODO: something meaningful on failure
        var client :HttpClient = new HttpClient();
        client.addEventListener(Event.CLOSE, event);
        client.addEventListener(Event.COMPLETE, handleComplete);
        client.addEventListener(Event.CONNECT, event);
        client.addEventListener(HttpDataEvent.DATA, handleData);
        client.addEventListener(HttpErrorEvent.ERROR, event);
        client.addEventListener(HttpStatusEvent.STATUS, event);

        client.request(new URI(_url), new Get());
    }

    /** @inheritDoc */
    // from UserCode
    public function connect (connectListener :Function, traceListener :Function) :void
    {
        try {
            _bridge.addEventListener("controlConnect", connectListener);
            if (traceListener != null) {
                _bridge.addEventListener(TraceEvent.TRACE, function (evt :TraceEvent) :void {
                    if (evt.trace != null) {
                        traceListener(evt.trace.join(" "));
                    }
                });
            }
            _instance = new _class();
            trace("New server instantiated!");
        }
        finally {
            _bridge = null; // prevent connecting twice
        }
    }

    /** @inheritDoc */
    // from UserCode
    public function release () :void
    {
        // TODO: forcibly kill off the domain etc.
        trace("Releasing " + this);
        releaseReferences();
    }

    /** @inheritDoc */
    // from Object
    public function toString () :String
    {
        return "HttpUserCode [url: " + _url + ", className: " + _className + 
            ", domain: " + _domain + ", class " + _class + 
            ", instance: " + _instance + "]";
    }

    /** Generically report an event. */
    protected function event (evt :Event) :void
    {
        trace("Got an event from the HTTP client: " + evt.type);
    }

    /** Receive some data from teh intarnets. */
    protected function handleData (evt :HttpDataEvent) :void
    {
        trace("Read " + evt.bytes.length + " bytes...");
        _bytes.writeBytes(evt.bytes);
    }

    /** Finished receiving data. */
    protected function handleComplete (evt :Event) :void
    {
        trace("Compiling bytecode into new Domain...");

        var success :Boolean = false;

        try {
            _bridge = new EventDispatcher();
            // TODO: is there a less cheesy way to make a unique domain id?
            var domainId :String = "UserCode-" + (++_lastId);
            _domain = Thane.spawnDomain(domainId, _bridge);
            // TODO: do we still need _bytes after this
            _domain.loadBytes(_bytes);
            trace("Successfully loaded! Testing...");

            _class = _domain.getClass(_className);
            trace("Server class in new domain: " + _class);

            success = _class != null;

        } catch (err :Error) {
            trace("Error loading user code: " + err.getStackTrace());

        } finally {

            try {
                _callback(success ? this : null);

            } catch (err :Error) {
                trace("Error invoking callback: " + err.getStackTrace());
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
        _bytes = null;
        _bridge = null;
        _domain = null;
        _class = null;
        _instance = null;
    }

    protected var _url :String;
    protected var _className :String;
    protected var _callback :Function;
    protected var _bytes :ByteArray = new ByteArray();
    protected var _bridge :EventDispatcher;
    protected var _domain :Domain;
    protected var _class :Class;
    protected var _instance :Object;

    protected static var _lastId :int;
}

}
