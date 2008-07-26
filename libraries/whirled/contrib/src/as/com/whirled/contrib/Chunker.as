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
 * The 'value' property will contain the received data.
 *
 * @eventType flash.events.Event.COMPLETE
 */
[Event(name="complete", type="com.threerings.util.ValueEvent")]

/**
 * Chunks data to other instances of the entity being used.
 *
 * Author: Ray Greenwell <ray "at" threerings.net>
 */
public class Chunker extends EventDispatcher
{
    /** A compression strategy that always compresses the data, regardless of whether it
     * saved any space. */
    public static const ALWAYS_COMPRESS :int = 0;

    /** A compression stragegy that tries to compress the data, but only sends the compressed
     * form if it would actually result in sending less chunks. */
    public static const TRY_COMPRESS :int = 1;

    /** A compression strategy that says: don't ever even waste time trying to compress. */
    public static const NEVER_COMPRESS :int = 2;

    /**
     * Construct a Chunker.
     *
     * @param ctrl your AvatarControl or ToyControl, etc.
     * @param msgName the name of the message to use for data sent using this chunker.
     * @param receivedCallback may be specified instead of listening for the complete event,
     * this function will be invoked when the data is received.
     * Signature: function (data :Object) :void;
     */
    public function Chunker (
        ctrl :EntityControl, msgName :String = "chunk", receivedCallback :Function = null)
    {
        _ctrl = ctrl;
        _msgName = msgName;

        _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessage);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);

        if (receivedCallback != null) {
            addEventListener(Event.COMPLETE, function (event :ValueEvent) :void {
                receivedCallback(event.value);
            });
        }
    }

    /**
     * Send this data to all instances of this entity in chunked and throttled messages.
     *
     * @param data a ByteArray or any other object graph that can be serialized to AMF3.
     * @param compressStrategy the strategy to take when deciding whether to compress the data.
     */
    public function send (data :Object, compressStrategy :int = TRY_COMPRESS) :void
    {
        // don't trust the specified array to be unmolested
        _outData = new ByteArray();
        _outTokens = NO_TOKENS;
        if (data is ByteArray) {
            _outData.writeBytes(data as ByteArray);

        } else {
            _outData.writeObject(data);
            _outTokens |= OBJECT_TOKEN;
        }

        if (compressStrategy == ALWAYS_COMPRESS) {
            _outData.compress();
            _outTokens |= COMPRESSED_TOKEN;

        } else if (compressStrategy == TRY_COMPRESS) {
            // only keep it compressed if we'd actually save a chunk
            var cData :ByteArray = new ByteArray();
            cData.writeBytes(_outData);
            var now :int = getTimer();
            cData.compress();
            if (countChunks(cData.length) < countChunks(_outData.length)) {
                _outData = cData;
                _outTokens |= COMPRESSED_TOKEN;
            } // else: don't compress
        }

        // send the first chunk now
        _outData.position = 0;
        checkSendChunk();
    }

    /**
     * Check to see if enough time has passed to send the next chunk.
     */
    protected function checkSendChunk () :void
    {
        if (_outData == null) {
            return;
        }
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

        var tokens :int = _outTokens;
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

        if ((tokens & END_TOKEN) == NO_TOKENS) {
            // We're not done, so check now to see if we want to send the next piece.
            checkSendChunk();
            return;
        }

        // We're all done!
        if ((tokens & COMPRESSED_TOKEN) != NO_TOKENS) {
            _inData.uncompress();
        }
        _inData.position = 0;
        var isObject :Boolean = ((tokens & OBJECT_TOKEN) != NO_TOKENS);
        var value :Object = isObject ? _inData.readObject() : _inData;
        _inData = null;
        dispatchEvent(new ValueEvent(Event.COMPLETE, value));
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

    /**
     * Counts the number of chunks to send data of the specified length.
     */
    protected static function countChunks (dataLength :int) :int
    {
        return int(dataLength / MAX_CHUNK_DATA) + ((0 == (dataLength % MAX_CHUNK_DATA)) ? 0 : 1);
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

    /** Some tokens describing the format of the _outData. */
    protected var _outTokens :int;

    /** The data we're currently receiving. */
    protected var _inData :ByteArray;

    /** Token constants. */
    protected static const NO_TOKENS :int = 0;
    protected static const START_TOKEN :int = 1 << 0;
    protected static const END_TOKEN :int = 1 << 1;
    protected static const OBJECT_TOKEN :int = 1 << 2;
    protected static const COMPRESSED_TOKEN :int = 1 << 3;

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
