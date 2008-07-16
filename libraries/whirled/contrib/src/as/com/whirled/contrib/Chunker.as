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
    public function Chunker (ctrl :EntityControl, msgName :String)
    {
        _ctrl = ctrl;
        _msgName = msgName;

        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessage);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
    }

    /**
     * Send this data to all instances of this entity. The message will be chunked
     * and sent very nicely.
     * TODO: accept arbitrary args?
     */
    public function send (data :ByteArray) :void
    {
        // don't trust the specified array to be unmolested
        _outData = new ByteArray();
        _outData.writeBytes(data);
        _outData.position = 0;

        // send the first chunk now
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
            var finalValue :ByteArray = _inData;
            _inData = null;
            finalValue.position = 0;
            dispatchEvent(new ValueEvent(Event.COMPLETE, finalValue));
        }

        checkSendChunk();
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

    /** The data we're currently receiving. */
    protected var _inData :ByteArray;

    /** Token constants. */
    protected static const NO_TOKENS :int = 0;
    protected static const START_TOKEN :int = 1 << 0;
    protected static const END_TOKEN :int = 1 << 1;

    /** The maximum size of our chunks. Whirled enforces a 1024 byte limit, after
     * it encodes into AMF3. So we lop off 10 bytes just to be safe. */
    protected static const MAX_CHUNK_DATA :int = 1014;

    /** The minimum time between sends. This is even fairly aggressive. Using
     * other values may "work" but then certain times they may not work, so you're
     * best off not screwing with this. */
    protected static const MIN_SEND_WAIT :int = 200;
}
}
