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

import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.utils.describeType; // function import

import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.GameSubControlClient;
import com.whirled.avrg.RoomSubControlClient;
import com.whirled.avrg.PlayerSubControlClient;
import com.whirled.avrg.LocalSubControl;
import com.whirled.avrg.MobSubControlClient;
import com.whirled.avrg.AgentSubControl;

import com.whirled.party.PartySubControl;

import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import com.threerings.util.StringUtil;
import com.threerings.util.Util;

/**
 * Declares all of the code objects available in the AVRG client and server api. Note that the
 * server functions declared here are proxies that will send a message to the server requesting
 * that it call the function and send a reply with the return value. The proxy functions are
 * auto generated and the real functions are defined in <code>ServerDefinitions</code>.
 * @see com.whirled.contrib.avrg.probe.ServerDefinitions
 */
public class Definitions
{
    /** All events that may occur on GameSubControlClient. */
    public static const GAME_EVENTS :Array = [
        AVRGameControlEvent.PLAYER_JOINED_GAME,
        AVRGameControlEvent.PLAYER_QUIT_GAME,
        MessageReceivedEvent.MESSAGE_RECEIVED
    ];

    /** All events that may occur on RoomSubControlClient. */
    public static const ROOM_EVENTS :Array = [
        AVRGameRoomEvent.PLAYER_ENTERED,
        AVRGameRoomEvent.PLAYER_LEFT,
        AVRGameRoomEvent.PLAYER_MOVED,
        AVRGameRoomEvent.AVATAR_CHANGED,
        AVRGameRoomEvent.MOB_CONTROL_AVAILABLE,
        AVRGameRoomEvent.SIGNAL_RECEIVED,
        AVRGameRoomEvent.ROOM_UNLOADED,
        MessageReceivedEvent.MESSAGE_RECEIVED
    ];

    /** All events that may occur on a property space. */
    public static const NET_EVENTS :Array = [
        PropertyChangedEvent.PROPERTY_CHANGED,
        ElementChangedEvent.ELEMENT_CHANGED,
    ];

    /** All events that may occur on PlayerSubControlClient. */
    public static const PLAYER_EVENTS :Array = [
        AVRGamePlayerEvent.TASK_COMPLETED,
        AVRGamePlayerEvent.ENTERED_ROOM,
        AVRGamePlayerEvent.LEFT_ROOM,
        MessageReceivedEvent.MESSAGE_RECEIVED
    ];

    /** All events that may occur on PartySubControl. */
    public static const PARTY_EVENTS :Array = [
        PartySubControl.PARTY_ENTERED,
        PartySubControl.PARTY_LEFT,
        PartySubControl.PLAYER_ENTERED_PARTY,
        PartySubControl.PLAYER_LEFT_PARTY,
        PartySubControl.PARTY_LEADER_CHANGED,
    ];

    /** All events that may occur on LocalSubControl. */
    public static const CLIENT_EVENTS :Array = [
        AVRGameControlEvent.SIZE_CHANGED
    ];

    /**
     * Creates new definitions.
     * @param ctrl the game control to use for our closures
     * @param makeDecoration the closure to use when creating a decoration
     */
    public function Definitions (ctrl :AVRGameControl, makeDecoration :Function)
    {
        _ctrl = ctrl;
        _makeDecoration = makeDecoration;

//        _client = introspectControl(ctrl);

        _client = {
            game: createGameFuncs(),
            room: createRoomFuncs(),
            player: createPlayerFuncs(),
            local: createLocalFuncs(),
            agent: createAgentFuncs(),
            mob: createMobFuncs(),
            party: createPartyFuncs()
        };
        _server = {
            misc: createServerMiscFuncs(),
            room: createServerRoomFuncs(),
            game: createServerGameFuncs(),
            player: createServerPlayerFuncs(),
            mob: createServerMobFuncs()
        };
    }

    /**
     * Get the categories of functions available on the AVRG client.
     * @param server if set, return only server categories, otherwise only client categories
     * @return an array of strings, one per category of function
     */
    public function getControls (server :Boolean) :Array
    {
        var keys :Array = Util.keys(server ? _server : _client);
        keys.sort();
        //trace("Got keys " + StringUtil.toString(keys));
        return keys;
    }

    /**
     * Get the functions for a given category.
     * @return an Array of <code>FunctionSpec</code> instances.
     */
    public function getFuncs (server :Boolean, ctrlName :String) :Array
    {
        var funcs :Array = Object(server ? _server : _client)[ctrlName];
        if (funcs == null) {
            throw new Error("Control " + ctrlName + " not found");
        }
        return funcs.slice(); // return a copy
    }

    /**
     * Add the given event listener function to all available event types and dispatchers.
     */
    public function addListenerToAll (listener :Function) :void
    {
        function add (ctrl :EventDispatcher, type :String) :void {
            ctrl.addEventListener(type, listener);
        }

        enumEvents(add);
    }

    /**
     * Removes the given event listener function from all available event types and dispatchers.
     */
    public function removeListenerFromAll (listener :Function) :void
    {
        function remove (ctrl :EventDispatcher, type :String) :void {
            ctrl.removeEventListener(type, listener);
        }
        
        enumEvents(remove);
    }

    /**
     * TODO
     * My idea was: introspect and figure out all the controls and functions on each.
     * These would be lacking in nice parameter names, but then, where we have methods defined
     * that matched the actual definitions, we could drop in the nice names. Rabbit hole. Punting.
     */
    protected function introspectControl (ctrl :Object) :Object
    {
        var o :Object = {
            controls: {},
            functions: {}
        };
        var name :String;
        var desc :XML = describeType(ctrl);
        trace(desc);
        for each (var func :XML in desc.method) {
            name = func.@name;
            if (isFunctionSuppressed(name)) {
                continue;
            }
            // TODO: well, I stopped here, because we don't actually handle sub-sub-controls well.
            // fuck.
        }
        for each (var subctrl :XML in desc.accessor) {
            name = subctrl.@name;
            o.controls[name] = introspectControl(ctrl[name]);
        }
        return o;
    }

    /**
     * Would we like to suppress a function with the specified name from our autogenerated list
     * of functions?
     */
    protected function isFunctionSuppressed (name :String) :Boolean
    {
        switch (name) {
        case "setUserProps":
        case "gotHostProps":
        case "isConnected":
        case "doBatch":
        case "callHostCode":
        case "addEventListener":
        case "removeEventListener":
        case "willTrigger":
        case "hasEventListener":
        case "dispatchEvent":
        case "toString":
            return true;

        default:
            return false;
        }
    }

    protected function enumEvents (functor :Function) :void
    {
        function forEach (ctrl :EventDispatcher, types :Array) :void {
            for each (var type :String in types) {
                functor(ctrl, type);
            }
        }

        forEach(_ctrl.game, GAME_EVENTS);
        forEach(_ctrl.game.props, NET_EVENTS);
        forEach(_ctrl.room, ROOM_EVENTS);
        forEach(_ctrl.room.props, NET_EVENTS);
        forEach(_ctrl.player, PLAYER_EVENTS);
        forEach(_ctrl.player.props, NET_EVENTS);
        forEach(_ctrl.local, CLIENT_EVENTS);
        //forEach(_ctrl.party, CLIENT_EVENTS);
    }

    protected function createRoomFuncs () :Array
    {
        var room :RoomSubControlClient = _ctrl.room;
        var funcs :Array = [
            new FunctionSpec("getRoomId", room.getRoomId),
            new FunctionSpec("getRoomName", room.getRoomName),
            new FunctionSpec("getPlayerIds", room.getPlayerIds),
            new FunctionSpec("isPlayerHere", room.isPlayerHere, [
                new Parameter("id", int)]),
            new FunctionSpec("getOccupantIds", room.getOccupantIds),
            new FunctionSpec("getOccupantName", room.getOccupantName, [
                new Parameter("playerId", int)]),
            new FunctionSpec("getMusicOwnerId", room.getMusicOwnerId),
            new FunctionSpec("getSpawnedMobs", room.getSpawnedMobs),
            new FunctionSpec("getRoomBounds", room.getRoomBounds),
            new FunctionSpec("getAvatarInfo", room.getAvatarInfo, [
                new Parameter("playerId", int)]),

            // client-only
            new FunctionSpec("getEntityIds", room.getEntityIds, [
                new Parameter("type", String, Parameter.OPTIONAL|Parameter.NULLABLE)]),
            new FunctionSpec("getEntityProperty", room.getEntityProperty, [
                new Parameter("key", String),
                new Parameter("entityId", String, Parameter.OPTIONAL|Parameter.NULLABLE)]),
            new FunctionSpec("canManageRoom", room.canManageRoom, [
                new Parameter("memberId", int, Parameter.OPTIONAL)]),
            new FunctionSpec("getMusicId3", room.getMusicId3)
        ];

        pushPropsFuncs(funcs, room.props);
        return funcs;
    }

    protected function createGameFuncs () :Array 
    {
        var game :GameSubControlClient = _ctrl.game;

        var funcs :Array = [
            new FunctionSpec("getPlayerIds", game.getPlayerIds),
            new FunctionSpec("getOccupantName", game.getOccupantName, [
                new Parameter("playerId", int)]),
            new FunctionSpec("getPartyIds", game.getPartyIds),
            new FunctionSpec("getLevelPacks", game.getLevelPacks),
            new FunctionSpec("getItemPacks", game.getItemPacks),
            new FunctionSpec("loadLevelPackData", game.loadLevelPackData, [
                new Parameter("ident", String),
                new CallbackParameter("onLoaded"),
                new CallbackParameter("onFailure")]),
            new FunctionSpec("loadItemPackData", game.loadItemPackData, [
                new Parameter("ident", String),
                new CallbackParameter("onLoaded"),
                new CallbackParameter("onFailure")]),
        ];
        pushPropsFuncs(funcs, game.props);
        return funcs;
    }

    protected function createPlayerFuncs () :Array
    {
        var player :PlayerSubControlClient = _ctrl.player;

        var funcs :Array = [
            new FunctionSpec("getPlayerId", player.getPlayerId),
            new FunctionSpec("getPlayerName", player.getPlayerName),
            new FunctionSpec("getPartyId", player.getPartyId),
            new FunctionSpec("getRoomId", player.getRoomId),
            new FunctionSpec("moveToRoom", player.moveToRoom, [
                new Parameter("roomId", int),
                new ArrayParameter("exitCoords", Number, Parameter.OPTIONAL|Parameter.NULLABLE)]),
            new FunctionSpec("deactivateGame", player.deactivateGame),
            new FunctionSpec("getPlayerItemPacks", player.getPlayerItemPacks),
            new FunctionSpec("getPlayerLevelPacks", player.getPlayerLevelPacks),
            new FunctionSpec("holdsTrophy", player.holdsTrophy, [new Parameter("ident", String)]),
            new FunctionSpec("completeTask", player.completeTask, [
                new Parameter("taskId", String),
                new Parameter("payout", Number)]),
            new FunctionSpec("playAvatarAction", player.playAvatarAction, [
                new Parameter("action", String)]),
            new FunctionSpec("setAvatarState", player.setAvatarState, [
                new Parameter("state", String)]),
            new FunctionSpec("setAvatarMoveSpeed", player.setAvatarMoveSpeed, [
                new Parameter("pixelsPerSecond", Number)]),
            new FunctionSpec("setAvatarLocation", player.setAvatarLocation, [
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number),
                new Parameter("orient", Number)]),
            new FunctionSpec("setAvatarOrientation", player.setAvatarOrientation, [
                new Parameter("orient", Number)]),
            new FunctionSpec("getCoins", player.getCoins),
            new FunctionSpec("getBars", player.getBars),

            // client-only
            new FunctionSpec("getAvatarMasterItemId", player.getAvatarMasterItemId),
            new FunctionSpec("requestConsumeItemPack", player.requestConsumeItemPack, [
                new Parameter("ident", String),
                new Parameter("msg", String)]),
            new FunctionSpec("getFacebookInfo", player.getFacebookInfo),
        ];
        pushPropsFuncs(funcs, player.props);
        pushPropsSetFuncs(funcs, player.props);
        return funcs;
    }

    protected function createLocalFuncs () :Array
    {
        var local :LocalSubControl = _ctrl.local;

        function getHitPointTester () :Function {
            return local.hitPointTester;
        }
        
        function getMobSpriteExporter () :Function {
            return local.mobSpriteExporter;
        }

        return [
            new FunctionSpec("feedback", local.feedback, [
                new Parameter("msg", String)]),
            new FunctionSpec("setShowChrome", local.setShowChrome, [
                new Parameter("show", Boolean)]),
            new FunctionSpec("showUI", local.showUI, [
                new Parameter("element", int),
                new ObjectParameter("arg", Parameter.OPTIONAL)]),
            new FunctionSpec("hideUI", local.hideUI, [
                new Parameter("element", int)]),
            new FunctionSpec("isUIShowing", local.isUIShowing, [
                new Parameter("element", int)]),
            new FunctionSpec("getPaintableArea", local.getPaintableArea, [
                new Parameter("full", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("setRoomViewBounds", local.setRoomViewBounds, [
                new RectangleParameter("bounds")]),
            new FunctionSpec("paintableToRoom", local.paintableToRoom, [
                new PointParameter("p")]),
            new FunctionSpec("roomToPaintable", local.roomToPaintable, [
                new PointParameter("p")]),
            new FunctionSpec("locationToRoom", local.locationToRoom, [
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number)]),
            new FunctionSpec("locationToPaintable", local.locationToPaintable, [
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number)]),
            new FunctionSpec("paintableToLocationAtDepth", local.paintableToLocationAtDepth, [
                new PointParameter("p"),
                new Parameter("depth", Number)]),
            new FunctionSpec("paintableToLocationAtHeight", local.paintableToLocationAtHeight, [
                new PointParameter("p"),
                new Parameter("height", Number)]),
            new FunctionSpec("setHitPointTester", local.setHitPointTester, [
                new CallbackParameter("tester")]),
            new FunctionSpec("getHitPointTester", getHitPointTester),
            new FunctionSpec("setMobSpriteExporter", local.setMobSpriteExporter, [
                new CallbackParameter("exporter")]),
            new FunctionSpec("getMobSpriteExporter", getMobSpriteExporter),
            new FunctionSpec("showPage", local.showPage, [
                new Parameter("token", String)]),
            new FunctionSpec("navigateToURL", local.navigateToURL, [
                new Parameter("url", String),
                new Parameter("target", String, Parameter.OPTIONAL)]),
            new FunctionSpec("showInvitePage", local.showInvitePage, [
                new Parameter("defmsg", String),
                new Parameter("token", String, Parameter.OPTIONAL)]),
            new FunctionSpec("getInviteToken", local.getInviteToken),
            new FunctionSpec("getInviterMemberId", local.getInviterMemberId),
        ];
    }

    protected function createAgentFuncs () :Array
    {
        var agent :AgentSubControl = _ctrl.agent;
        return [
            new FunctionSpec("sendMessage", agent.sendMessage, [
                new Parameter("name", String),
                new ObjectParameter("value")]),
        ];
    }

    protected function createMobFuncs () :Array
    {
        var mob :TargetedSubCtrlDef = new TargetedSubCtrlDef(
            _ctrl.room.getMobSubControl, new Parameter("id", String));

        mob.addMethod("setHotSpot", function (ctrl :MobSubControlClient) :Function {
            return ctrl.setHotSpot;
        }, [new Parameter("x", Number),
            new Parameter("y", Number),
            new Parameter("height", Number, Parameter.OPTIONAL)]);

        mob.addMethod("setDecoration", function (ctrl :MobSubControlClient) :Function {
            return function (...args) :* {
                args.unshift(_makeDecoration());
                return ctrl.setDecoration.apply(null, args);
            }
        });

        mob.addMethod("removeDecoration", function (ctrl :MobSubControlClient) :Function {
            return ctrl.removeDecoration;
        });

        return mob.toSpecs();
    }

    protected function createPartyFuncs () :Array
    {
        var party :TargetedSubCtrlDef = new TargetedSubCtrlDef(
            _ctrl.game.getParty, new Parameter("partyId", int));

        party.addMethod("getPartyId", function (ctrl :PartySubControl) :Function {
            return ctrl.getPartyId;
        });
        party.addMethod("getName", function (ctrl :PartySubControl) :Function {
            return ctrl.getName;
        });
        party.addMethod("getGroupId", function (ctrl :PartySubControl) :Function {
            return ctrl.getGroupId;
        });
        party.addMethod("getGroupName", function (ctrl :PartySubControl) :Function {
            return ctrl.getGroupName;
        });
        party.addMethod("getGroupLogo", function (ctrl :PartySubControl) :Function {
            return ctrl.getGroupLogo;
        });
        party.addMethod("getLeaderId", function (ctrl :PartySubControl) :Function {
            return ctrl.getLeaderId;
        });
        party.addMethod("getPlayerIds", function (ctrl :PartySubControl) :Function {
            return ctrl.getPlayerIds;
        });
        return party.toSpecs();
    }

    protected function pushPropsFuncs (funcs :Array, props :PropertyGetSubControl) :void
    {
        funcs.splice(funcs.length, 0,
            new FunctionSpec("props.get", props.get, [
                new Parameter("name", String)]),
            new FunctionSpec("props.getPropertyNames", props.getPropertyNames, [
                new Parameter("prefix", String, Parameter.OPTIONAL)])
        );
    }

    protected function pushPropsSetFuncs (funcs :Array, props :PropertySubControl) :void
    {
        funcs.splice(funcs.length, 0,
            new FunctionSpec("props.set", props.set, [
                new Parameter("name", String),
                new ObjectParameter("value", Parameter.NULLABLE)]),
            new FunctionSpec("props.setAt", props.setAt, [
                new Parameter("name", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", props.setIn, [
                new Parameter("name", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)])
        );
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerMiscFuncs () :Array
    {
        return [
            new FunctionSpec("dump", proxy("misc", "dump")),
        ];
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerGameFuncs () :Array
    {
        return [
            new FunctionSpec("getPlayerIds", proxy("game", "getPlayerIds")),
            new FunctionSpec("getItemPacks", proxy("game", "getItemPacks")),
            new FunctionSpec("getLevelPacks", proxy("game", "getLevelPacks")),
            new FunctionSpec("sendMessage", proxy("game", "sendMessage"), [
                new Parameter("name", String),
                new ObjectParameter("value")]),
            new FunctionSpec("props.get", proxy("game", "props.get"), [
                new Parameter("propName", String)]),
            new FunctionSpec("props.getPropertyNames", proxy("game", "props.getPropertyNames"), [
                new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("props.set", proxy("game", "props.set"), [
                new Parameter("propName", String),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setAt", proxy("game", "props.setAt"), [
                new Parameter("propName", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", proxy("game", "props.setIn"), [
                new Parameter("propName", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
        ];
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerPlayerFuncs () :Array
    {
        return [
            new FunctionSpec("getPlayerId", proxy("player", "getPlayerId"), [
                new Parameter("playerId", int)]),
            new FunctionSpec("getRoomId", proxy("player", "getRoomId"), [
                new Parameter("playerId", int)]),
            new FunctionSpec("holdsTrophy", proxy("player", "holdsTrophy"), [
                new Parameter("playerId", int),
                new Parameter("ident", String)]),
            new FunctionSpec("awardTrophy", proxy("player", "awardTrophy"), [
                new Parameter("playerId", int),
                new Parameter("ident", String)]),
            new FunctionSpec("awardPrize", proxy("player", "awardPrize"), [
                new Parameter("playerId", int),
                new Parameter("ident", String)]),
            new FunctionSpec("getPlayerItemPacks", proxy("player", "getPlayerItemPacks"), [
                new Parameter("playerId", int)]),
            new FunctionSpec("getPlayerLevelPacks", proxy("player", "getPlayerLevelPacks"), [
                new Parameter("playerId", int)]),
            new FunctionSpec("deactivateGame", proxy("player", "deactivateGame"), [
                new Parameter("playerId", int)]),
            new FunctionSpec("completeTask", proxy("player", "completeTask"), [
                new Parameter("playerId", int),
                new Parameter("taskId", String),
                new Parameter("payout", Number)]),
            new FunctionSpec("playAvatarAction", proxy("player", "playAvatarAction"), [
                new Parameter("playerId", int),
                new Parameter("action", String)]),
            new FunctionSpec("setAvatarState", proxy("player", "setAvatarState"), [
                new Parameter("playerId", int),
                new Parameter("state", String)]),
            new FunctionSpec("setAvatarMoveSpeed", proxy("player", "setAvatarMoveSpeed"), [
                new Parameter("playerId", int),
                new Parameter("pixelsPerSecond", Number)]),
            new FunctionSpec("setAvatarLocation", proxy("player", "setAvatarLocation"), [
                new Parameter("playerId", int),
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number),
                new Parameter("orient", Number)]),
            new FunctionSpec("setAvatarOrientation", proxy("player", "setAvatarOrientation"), [
                new Parameter("playerId", int),
                new Parameter("orient", Number)]),
            new FunctionSpec("sendMessage", proxy("player", "sendMessage"), [
                new Parameter("playerId", int),
                new Parameter("name", String),
                new ObjectParameter("value")]),
            new FunctionSpec("props.get", proxy("player", "props.get"), [
                new Parameter("playerId", int),
                new Parameter("propName", String)]),
            new FunctionSpec("props.getPropertyNames", proxy("player", "props.getPropertyNames"), [
                new Parameter("playerId", int),
                new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("props.set", proxy("player", "props.set"), [
                new Parameter("playerId", int),
                new Parameter("propName", String),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setAt", proxy("player", "props.setAt"), [
                new Parameter("playerId", int),
                new Parameter("propName", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", proxy("player", "props.setIn"), [
                new Parameter("playerId", int),
                new Parameter("propName", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
        ];
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerRoomFuncs () :Array
    {
        return [
            new FunctionSpec("getRoomId", proxy("room", "getRoomId"), [
                new Parameter("roomId", int)]),
            new FunctionSpec("getPlayerIds", proxy("room", "getPlayerIds"), [
                new Parameter("roomId", int)]),
            new FunctionSpec("isPlayerHere", proxy("room", "isPlayerHere"), [
                new Parameter("roomId", int),
                new Parameter("id", int)]),
            new FunctionSpec("getAvatarInfo", proxy("room", "getAvatarInfo"), [
                new Parameter("roomId", int),
                new Parameter("playerId", int)]),
            new FunctionSpec("getRoomBounds", proxy("room", "getRoomBounds"), [
                new Parameter("roomId", int)]),
            new FunctionSpec("spawnMob", proxy("room", "spawnMob"), [
                new Parameter("roomId", int),
                new Parameter("id", String),
                new Parameter("name", String),
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number)]),
            new FunctionSpec("despawnMob", proxy("room", "despawnMob"), [
                new Parameter("roomId", int),
                new Parameter("id", String)]),
            new FunctionSpec("getSpawnedMobs", proxy("room", "getSpawnedMobs"), [
                new Parameter("roomId", int)]),
            new FunctionSpec("sendMessage", proxy("room", "sendMessage"), [
                new Parameter("roomId", int),
                new Parameter("name", String),
                new ObjectParameter("value")]),
            new FunctionSpec("sendSignal", proxy("room", "sendSignal"), [
                new Parameter("roomId", int),
                new Parameter("name", String),
                new ObjectParameter("value")]),
            new FunctionSpec("props.get", proxy("room", "props.get"), [
                new Parameter("roomId", int),
                new Parameter("propName", String)]),
            new FunctionSpec("props.getPropertyNames", proxy("room", "props.getPropertyNames"), [
                new Parameter("roomId", int),
                new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("props.set", proxy("room", "props.set"), [
                new Parameter("roomId", int),
                new Parameter("propName", String),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setAt", proxy("room", "props.setAt"), [
                new Parameter("roomId", int),
                new Parameter("propName", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", proxy("room", "props.setIn"), [
                new Parameter("roomId", int),
                new Parameter("propName", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
        ];
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerMobFuncs () :Array
    {
        return [
            new FunctionSpec("moveTo", proxy("mob", "moveTo"), [
                new Parameter("roomId", int),
                new Parameter("mobId", String),
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number)]),
        ];
    }

    protected function proxy (prefix :String, name :String) :Function
    {
        function sendMsg (sequenceId :int, ...args) :void {
            trace("Sending message: " + args);
            var message :Object = {};
            message.name = prefix + "." + name;
            message.params = args;
            message.sequenceId = sequenceId;
            _ctrl.agent.sendMessage(ServerModule.REQUEST_BACKEND_CALL, message);
        }

        return sendMsg;
    }

    protected var _ctrl :AVRGameControl;
    protected var _makeDecoration :Function;
    protected var _client :Object;
    protected var _server :Object;
}
}
