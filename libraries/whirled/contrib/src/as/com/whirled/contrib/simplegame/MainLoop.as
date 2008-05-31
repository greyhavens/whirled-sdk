// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.simplegame {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.utils.getTimer;

public final class MainLoop
{
    public static function get instance () :MainLoop
    {
        return g_instance;
    }

    public function MainLoop (hostSprite :Sprite, keyDispatcher :IEventDispatcher = null)
    {
        if (null == hostSprite) {
            throw new ArgumentError("hostSprite must be non-null");
        }

        if (null != g_instance) {
            throw new Error("only one MainLoop may exist at a time");
        }

        g_instance = this;

        _hostSprite = hostSprite;
        _keyDispatcher = (null != keyDispatcher ? keyDispatcher : _hostSprite);
    }

    public function addUpdatable (obj :Updatable) :void
    {
        _updatables.push(obj);
    }

    public function removeUpdatable (obj :Updatable) :void
    {
        ArrayUtil.removeFirst(_updatables, obj);
    }

    /**
     * Returns the top mode on the mode stack, or null
     * if the stack is empty.
     */
    public function get topMode () :AppMode
    {
        if (_modeStack.length == 0) {
            return null;
        } else {
            return ((_modeStack[_modeStack.length - 1]) as AppMode);
        }
    }

    /**
     * Initializes structures required by the framework, including the
     * ResourceLoaderRegistry and the Rand utility.
     */
    public function setup () :void
    {
        if (_hasSetup) {
            return;
        }

        Rand.setup();

        // instantiate singletons
        new ResourceManager();
        new AudioManager();

        // add resource factories
        ResourceManager.instance.registerResourceType("image", ImageResource);
        ResourceManager.instance.registerResourceType("swf", SwfResource);
        ResourceManager.instance.registerResourceType("xml", XmlResource);
        ResourceManager.instance.registerResourceType("sound", SoundResource);

        _hasSetup = true;
    }

    /**
     * Call this function before the application shuts down to release
     * memory and disconnect event handlers.
     *
     * Most applications will want to install an Event.REMOVED_FROM_STAGE
     * handler on the main sprite, and call shutdown from there.
     */
    public function shutdown () :void
    {
        if (_running) {
            _hostSprite.removeEventListener(Event.ENTER_FRAME, update);
            _keyDispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
            _keyDispatcher.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
        }

        this.popAllModes();
        this.handleModeTransitions();

        if (_hasSetup) {
            AudioManager.instance.shutdown();
            ResourceManager.instance.shutdown();

            _hasSetup = false;
        }

        g_instance = null;
    }

    /**
     * Kicks off the MainLoop. Game updates will start happening after this
     * function is called.
     */
    public function run () :void
    {
        if (_running) {
            return;
        }

        // ensure that proper setup has completed
        setup();

        _running = true;

        _hostSprite.addEventListener(Event.ENTER_FRAME, update);
        _keyDispatcher.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
        _keyDispatcher.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);

        _lastTime = this.elapsedSeconds;
    }

    protected function onKeyDown (e :KeyboardEvent) :void
    {
        var topMode :AppMode = this.topMode;
        if (null != topMode) {
            topMode.onKeyDown(e.keyCode);
        }
    }

    protected function onKeyUp (e :KeyboardEvent) :void
    {
        var topMode :AppMode = this.topMode;
        if (null != topMode) {
            topMode.onKeyUp(e.keyCode);
        }
    }

    /**
     * Pushes a mode to the mode stack.
     * Mode changes take effect before game updates.
     */
    public function pushMode (mode :AppMode) :void
    {
        if (null == mode) {
            throw new ArgumentError("mode must be non-null");
        }

        createModeTransition(mode, TRANSITION_PUSH);
    }

    /**
     * Pops the top mode from the mode stack.
     * Mode changes take effect before game updates.
     */
    public function popMode () :void
    {
        createModeTransition(null, TRANSITION_POP);
    }

    /**
     * Pops the top mode from the stack, and pushes
     * a new mode in its place.
     * Mode changes take effect before game updates.
     */
    public function changeMode (mode :AppMode) :void
    {
        if (null == mode) {
            throw new ArgumentError("mode must be non-null");
        }

        createModeTransition(mode, TRANSITION_CHANGE);
    }

    /**
     * Pops all modes from the mode stack.
     * Mode changes take effect before game updates.
     */
    public function popAllModes () :void
    {
        createModeTransition(null, TRANSITION_UNWIND);
    }

    /**
     * Pops modes from the stack until the specified mode is reached.
     * If the specified mode is not reached, it will be pushed to the top
     * of the mode stack.
     * Mode changes take effect before game updates.
     */
    public function unwindToMode (mode :AppMode) :void
    {
        if (null == mode) {
            throw new ArgumentError("mode must be non-null");
        }

        createModeTransition(mode, TRANSITION_UNWIND);
    }

    protected function createModeTransition (mode :AppMode, transitionType :uint) :void
    {
        var modeTransition :Object = new Object();
        modeTransition.mode = mode;
        modeTransition.transitionType = transitionType;
        _pendingModeTransitionQueue.push(modeTransition);
    }

    protected function handleModeTransitions () :void
    {
        if (_pendingModeTransitionQueue.length <= 0) {
            return;
        }

        // save 'this' for local functions
        var thisMainLoop :MainLoop = this;

        var initialTopMode :AppMode = this.topMode;

        function doPopMode () :void {
            var topMode :AppMode = thisMainLoop.topMode;
            if (null == topMode) {
                throw new Error("Can't pop from an empty mode stack");
            }

            // if the top mode is popped, make sure it's exited first
            if (topMode == initialTopMode) {
                initialTopMode.exitInternal();
                initialTopMode = null;
            }

            topMode.destroyInternal();

            _modeStack.pop();
            _hostSprite.removeChild(topMode.modeSprite);
        }

        function doPushMode (newMode :AppMode) :void {
            if (null == newMode) {
                throw new Error("Can't push a null mode to the mode stack");
            }

            _modeStack.push(newMode);
            _hostSprite.addChild(newMode.modeSprite);
        }

        // create a new _pendingModeTransitionQueue right now
        // so that we can properly handle mode transition requests
        // that occur during the processing of the current queue
        var transitionQueue :Array = _pendingModeTransitionQueue;
        _pendingModeTransitionQueue = [];

        for each (var transition :* in transitionQueue) {
            var type :uint = transition.transitionType as uint;
            var mode :AppMode = transition.mode as AppMode;

            switch (type) {
            case TRANSITION_PUSH:
                doPushMode(mode);
                break;

            case TRANSITION_POP:
                doPopMode();
                break;

            case TRANSITION_CHANGE:
                // a pop followed by a push
                if (null != this.topMode) {
                    doPopMode();
                }
                doPushMode(mode);
                break;

            case TRANSITION_UNWIND:
                // pop modes until we find the one we're looking for
                while (_modeStack.length > 0 && this.topMode != mode) {
                    doPopMode();
                }

                Assert.isTrue(this.topMode == mode || _modeStack.length == 0);

                if (_modeStack.length == 0 && null != mode) {
                    doPushMode(mode);
                }
                break;
            }
        }

        var topMode :AppMode = this.topMode;
        if (topMode != initialTopMode) {
            if (null != initialTopMode) {
                initialTopMode.exitInternal();
            }

            if (null != topMode) {
                if (!topMode._hasSetup) {
                    topMode.setupInternal();
                }

                topMode.enterInternal();
            }
        }
    }

    protected function update (e :Event) :void
    {
        this.handleModeTransitions();

        // how much time has elapsed since last frame?
        var newTime :Number = this.elapsedSeconds;
        var dt :Number = newTime - _lastTime;

        _fps = 1 / dt;

        // update all our "updatables"
        for each (var updatable :Updatable in _updatables) {
            updatable.update(dt);
        }

        // update the top mode
        var theTopMode :AppMode = this.topMode;
        if (null != theTopMode) {
            theTopMode.update(dt);
        }

        // update audio
        AudioManager.instance.update(dt);

        _lastTime = newTime;
    }

    /** Returns the number of seconds that have elapsed since the application started. */
    public function get elapsedSeconds () :Number
    {
        return (getTimer() / 1000); // getTimer() returns a value in milliseconds
    }

    /**
     * Returns the approximate frames-per-second that the application
     * is running at.
     */
    public function get fps () :Number
    {
        return _fps;
    }

    protected static var g_instance :MainLoop;

    protected var _hostSprite :Sprite;
    protected var _keyDispatcher :IEventDispatcher;
    protected var _hasSetup :Boolean = false;
    protected var _running :Boolean = false;
    protected var _lastTime :Number;
    protected var _modeStack :Array = [];
    protected var _pendingModeTransitionQueue :Array = [];
    protected var _updatables :Array = [];

    protected var _fps :Number = 0;

    // mode transition constants
    internal static const TRANSITION_PUSH :uint = 0;
    internal static const TRANSITION_POP :uint = 1;
    internal static const TRANSITION_CHANGE :uint = 2;
    internal static const TRANSITION_UNWIND :uint = 3;
}

}
