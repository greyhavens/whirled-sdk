//
// $Id$

package com.whirled.contrib {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;

import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer; // function

import com.threerings.util.ValueEvent;

import com.whirled.ControlEvent;
import com.whirled.EntityControl;

/**
 * Dispatched when the chunks are reconstituted and ready to use.
 *
 * @eventType Event.COMPLETE
 */
[Event(name="complete", type="com.threerings.util.ValueEvent")]

/**
 * Chunks data to other instances of the entity being used.
 */
public class Chunker extends EventDispatcher
{
    public function Chunker (ctrl :EntityControl, msgName :String = "data")
    {
        _ctrl = ctrl;
        _msgName = msgName;

        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessage);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
    }

    /**
     * Send this data to all instances of this entity. The message will be chunked
     * and sent very nicely.
     */
    public function send (data :ByteArray) :void
    {
        // don't trust the specified array to be unmolested
        _outData = new ByteArray();
        _outData.writeBytes(data);
        _outData.position = 0;
        _isObject = false;

        // send the first chunk now
        checkSendChunk();
    }

    /**
     * Send the specified object, which must be AMF3 encodeable, to all
     * instances of this entity.
     */
    public function sendObject (object :Object) :void
    {
        _outData = new ByteArray();
        _outData.writeObject(object);
        _outData.position = 0;
        _isObject = true;

        checkSendChunk();
    }

    /**
     * Check to see if enough time has passed to send the next chunk.
     */
    protected function checkSendChunk () :void
    {
        const now :int = getTimer();
        const wait :int = _nextSend - now;
        if (wait <= 0) {
            sendChunk();

        } else {
            if (_timer == null) {
                _timer = new Timer(1, 1);
                _timer.addEventListener(TimerEvent.TIMER, sendChunk);
            }
            _timer.delay = wait;
            _timer.start();
        }
    }

    /**
     * Send the next chunk.
     */
    protected function sendChunk (... ignored) :void
    {
        const toSend :int = Math.min(MAX_CHUNK_DATA, _outData.bytesAvailable);
        const newPosition :int = _outData.position + toSend;

        var tokens :int = NO_TOKENS;
        if (_outData.position == 0) {
            tokens |= START_TOKEN;
        }
        if (newPosition == _outData.length) {
            tokens |= END_TOKEN;
            if (_isObject) {
                tokens |= OBJECT_TOKEN;
            }
        }

        var outBytes :ByteArray = new ByteArray();
        outBytes.writeByte(tokens);
        outBytes.writeBytes(_outData, _outData.position, toSend);
        _outData.position = newPosition;

        _ctrl.sendMessage(_msgName, outBytes);
        _nextSend = getTimer() + MIN_SEND_WAIT;

        // if we're actually done, clear the outdata
        if (newPosition == _outData.length) {
            _outData = null;
        }
    }

    /**
     * Handle a received chunk.
     */
    protected function chunkReceived (inBytes :ByteArray) :void
    {
        const tokens :int = inBytes.readByte();
        if ((tokens & START_TOKEN) != NO_TOKENS) {
            _inData = new ByteArray();
        }
        if (_inData == null) {
            return; // wait for the start...
        }

        inBytes.readBytes(_inData, _inData.position);
        _inData.position += inBytes.length - 1;

        if ((tokens & END_TOKEN) != NO_TOKENS) {
            // We're done!
            _inData.position = 0;
            var isObject :Boolean = ((tokens & OBJECT_TOKEN) != NO_TOKENS);
            var value :Object = isObject ? _inData.readObject() : _inData;
            _inData = null;
            dispatchEvent(new ValueEvent(Event.COMPLETE, value));

        } else {
            // We're not done, so check now to see if we want to send the next piece.
            checkSendChunk();
        }
    }

    /**
     * Handles ControlEvent.MESSAGE_RECEIVED.
     */
    protected function handleMessage (event :ControlEvent) :void
    {
        if (event.name == _msgName) {
            chunkReceived(event.value as ByteArray);
        }
    }

    /**
     * Handles Event.UNLOAD.
     */
    protected function handleUnload (event :Event) :void
    {
        if (_timer != null) {
            _timer.stop();
        }
    }

    /** The entity control we're using. */
    protected var _ctrl :EntityControl;

    /** The message name we're using. */
    protected var _msgName :String;

    /** The Timer used to throttle sends. Only used on the sender. */
    protected var _timer :Timer;

    /** The time at which we should send the next chunk. */
    protected var _nextSend :int;

    /** The data we're currently sending. */
    protected var _outData :ByteArray;

    /** Whether the _outData is an object and should be decoded on the other end. */
    protected var _isObject :Boolean;

    /** The data we're currently receiving. */
    protected var _inData :ByteArray;

    /** Token constants. */
    protected static const NO_TOKENS :int = 0;
    protected static const START_TOKEN :int = 1 << 0;
    protected static const END_TOKEN :int = 1 << 1;
    protected static const OBJECT_TOKEN :int = 1 << 2;

    /** The maximum size of our chunks. Whirled enforces a post-AMF3 1024 byte limit,
     * so we want to use all of that. In AMF3, one byte is used to encode "ByteArray", followed
     * by the length, which will be two bytes because 1024-ish is larger than 2^7 but less
     * than 2^14. So the AMF3 encoding takes 3 bytes, plus there's our 1 byte header for each
     * chunk, leaving us 1020 bytes for our chunk size. */
    protected static const MAX_CHUNK_DATA :int = 1020;

    /** The minimum time between sends. This is even fairly aggressive. Using
     * other values may "work" but then certain times they may not work, so you're
     * best off not screwing with this. */
    protected static const MIN_SEND_WAIT :int = 200;
}
}
