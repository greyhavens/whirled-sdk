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

package com.whirled.contrib.avrg.probe {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;
import flash.events.Event;
import com.whirled.avrg.AVRGameControl;
import com.whirled.net.MessageReceivedEvent;
import com.threerings.util.StringUtil;
import com.threerings.util.ClassUtil;

/**
 * The main interface for calling all AVRG functions on the client and on the server. By default,
 * it consists of two tabs at the very top, the client tab and the server tab. Each of these, in
 * turn, contains a series of tabs that are the categories of API functions that may be called,
 * each one corresponding roughly to a sub control type. Within each of these tabs are
 * <code>FunctionPanel</code> instances containing all the functions in that group. The panel logs
 * all events received from the server.
 *
 * <p>TODO: control which events are logged.</p>
 */
public class ClientPanel extends Sprite
{
    /**
     * Converts a reference to a string, interpreting fields directly if it is a simple object.
     * Also has a special case for <code>AVRGameAvatar</code> because it has no toString method.
     */
    public static function toString (obj :*) :String
    {
        if (ClassUtil.tinyClassName(obj) == 'AVRGameAvatar') {
            return StringUtil.simpleToString(obj);
        }
        return StringUtil.toString(obj);
    }

    /**
     * Creates a new client panel. If the given ctrl has no mob sprite exporter, a test one is
     * assigned.
     */
    public function ClientPanel (ctrl :AVRGameControl)
    {
        _ctrl = ctrl;
        _tabPanel = new TabPanel();
        addChild(_tabPanel);

        graphics.beginFill(0xffffff);
        graphics.drawRect(0, 0, 350, 250);
        graphics.endFill();

        _defs = new Definitions(_ctrl, function () :Sprite {
            return new DecorationSprite();
        });

        var client :TabPanel = new TabPanel();
        _tabPanel.addTab("client", new Button("Client"), client);

        var key :String;
        for each (key in _defs.getControls(false)) {
            client.addTab(key, new Button(StringUtil.capitalize(key)),
                new FunctionPanel(_ctrl, _defs.getFuncs(false, key), false));
        }

        var server :TabPanel = new TabPanel();
        _tabPanel.addTab("server", new Button("Server"), server);

        for each (key in _defs.getControls(true)) {
            server.addTab(key, new Button(StringUtil.capitalize(key)),
                new FunctionPanel(_ctrl, _defs.getFuncs(true, key), true));
        }

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);
    }

    public function handleAdded (evt :Event) :void
    {
        trace("Added event " + evt + ", target: " + evt.target + ", currentTarget: " + evt.currentTarget);

        if (evt.target != this) {
            return;
        }

        trace("Adding client panel");
        _defs.addListenerToAll(logEvent);

        _ctrl.player.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleGameMessage);

        if (_ctrl.local.mobSpriteExporter == null) {
            _ctrl.local.setMobSpriteExporter(createMob);
        }
    }

    public function handleRemoved (evt :Event) :void
    {
        trace("Removed event " + evt + ", target: " + evt.target + ", currentTarget: " + evt.currentTarget);

        if (evt.target != this) {
            return;
        }

        trace("Removing client panel");

        _defs.removeListenerFromAll(logEvent);

        _ctrl.player.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleGameMessage);

        if (_ctrl.local.mobSpriteExporter == createMob) {
            _ctrl.local.setMobSpriteExporter(null);
        }
    }

    protected function handleGameMessage (evt :MessageReceivedEvent) :void
    {
        if (evt.name == ServerModule.BACKEND_CALL_RESULT) {
            _ctrl.local.feedback(
                "Result received from server agent: " + ClientPanel.toString(evt.value));

        } else if (evt.name == ServerModule.CALLBACK_INVOKED) {
            _ctrl.local.feedback(
                "Callback invoked on server agent: " + ClientPanel.toString(evt.value));

        } else if (evt.name == ServerStub.ACKNOWLEDGED) {
            _ctrl.local.feedback("Server stub now active: " + evt.value);
        }
    }

    protected function logEvent (event :Event) :void
    {
        _ctrl.local.feedback(String(event));
        trace("Got event [" + _ctrl.player.getPlayerId() + "]: " + event);
    }

    protected function createMob (id :String) :DisplayObject
    {
        return new MobSprite(id);
    }

    protected var _ctrl :AVRGameControl;
    protected var _tabPanel :TabPanel;
    protected var _defs :Definitions
}

}
