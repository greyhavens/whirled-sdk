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

import com.threerings.util.ClassUtil;
import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.MobSubControlServer;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.PropertySubControl;

/**
 * Encapsulates the function definitions available to an AVRG server agent.
 */
public class ServerDefinitions
{
    // TODO: tweak these to be specific to the server event set

    /** Events that apply to a GameSubControlServer. */
    public static const GAME_EVENTS :Array = Definitions.GAME_EVENTS;

    /** Events that apply to a RoomSubControlServer. */
    public static const ROOM_EVENTS :Array = Definitions.ROOM_EVENTS;

    /** Events that apply to a property space (.props member). */
    public static const NET_EVENTS :Array = Definitions.NET_EVENTS;

    /** Events that apply to a PlayerSubControlServer. */
    public static const PLAYER_EVENTS :Array = Definitions.PLAYER_EVENTS;

    /**
     * Creates a new set of server definitions based on a given top-level game control.
     */
    public function ServerDefinitions (ctrl :AVRServerGameControl)
    {
        _ctrl = ctrl;

        _funcs.room = createRoomFuncs();
        _funcs.misc = createMiscFuncs();
        _funcs.game = createGameFuncs();
        _funcs.player = createPlayerFuncs();
        _funcs.mob = createMobFuncs();
    }

    /**
     * Lookup a function by scoped name. This is the category followed by a dot followed by the
     * function name. For example, "room.getPlayerIds".
     */
    public function findByName (name :String) :FunctionSpec
    {
        var dot :int = name.indexOf(".");
        var scope :String = name.substr(0, dot);
        name = name.substr(dot + 1);
        var fnArray :Array = _funcs[scope];
        if (fnArray == null) {
            return null;
        }
        for each (var spec :FunctionSpec in fnArray) {
            if (spec.name == name) {
                return spec;
            }
        }
        return null;
    }

    /**
     * Print out the RPC versions of all server functions suitable for pasting into client 
     * definitions.
     */
    public function dump () :void
    {
        for (var scope :String in _funcs) {
            trace("    // AUTO GENERATED from ServerDefinitions");
            trace("    protected function createServer" + scope.substr(0, 1).toUpperCase() + 
                  scope.substr(1) + "Funcs () :Array");
            trace("    {");
            trace("        return [");
            for each (var fnSpec :FunctionSpec in _funcs[scope]) {
                var proxy :String = "proxy(\"" + scope + "\", \"" + fnSpec.name + "\")";
                var specStart :String = "            new FunctionSpec(\"" + fnSpec.name + "\"";
                specStart += ", " + proxy;
                if (fnSpec.parameters.length == 0) {
                    trace(specStart + "),");
                } else {
                    specStart += ", ["
                    trace(specStart);
                
                    for (var ii :int = 0; ii < fnSpec.parameters.length; ++ii) {
                        var param :Parameter = fnSpec.parameters[ii];
                        var paramStr :String = ClassUtil.getClassName(param);
                        paramStr += "(\"" + param.name + "\"";
                        if (ClassUtil.getClass(param) != ObjectParameter) {
                            paramStr += ", " + ClassUtil.getClassName(param.type);
                        }
                        if (param.optional || param.nullable) {
                            var flags :Array = [];
                            if (param.optional) {
                                flags.push("Parameter.OPTIONAL");
                            }
                            if (param.nullable) {
                                flags.push("Parameter.NULLABLE");
                            }
                            var flagStr :String = flags[0];
                            for (var jj :int = 1; jj < flags.length; ++jj) {
                                flagStr += "|" + flags[jj];
                            }
                            paramStr += ", " + flagStr;
                        }
                        paramStr += ")";
                        if (ii == fnSpec.parameters.length - 1) {
                            paramStr += "]),";
                        } else {
                            paramStr += ",";
                        }
                        trace("                new " + paramStr);
                    }
                }
            }
            trace("        ];");
            trace("    }");
            trace("");
        }
    }

    protected function createGameFuncs () :Array
    {
        var funcs :Array = [
            new FunctionSpec("getPlayerIds", _ctrl.game.getPlayerIds),
            new FunctionSpec("getItemPacks", _ctrl.game.getItemPacks),
            new FunctionSpec("getLevelPacks", _ctrl.game.getLevelPacks),
            new FunctionSpec("sendMessage", _ctrl.game.sendMessage, [
                new Parameter("name", String),
                new ObjectParameter("value")])];
        var props :Array = [];

        pushPropsFuncs(props, "game", function (id :int) :PropertySubControl {
            return _ctrl.game.props;
        });

        // stub out those id parameters
        function prependZero (func :Function) :Function {
            function stubby (...args) :* {
                args.unshift(0);
                return func.apply(null, args);
            }
            return stubby;
        }

        for (var ii :int = 0; ii < props.length; ++ii) {
            var fs :FunctionSpec = props[ii];
            var params :Array = fs.parameters;
            params.shift();
            props[ii] = new FunctionSpec(fs.name, prependZero(fs.func), params);
        }

        funcs.push.apply(funcs, props);
        return funcs;
    }

    protected function createRoomFuncs () :Array
    {
        var room :TargetedSubCtrlDef = new TargetedSubCtrlDef(
            _ctrl.getRoom, new Parameter("roomId", int));

        room.addMethod("getRoomId", function (room :RoomSubControlServer) :Function {
            return room.getRoomId;
        });

        room.addMethod("getPlayerIds", function (room :RoomSubControlServer) :Function {
            return room.getPlayerIds;
        });

        room.addMethod("isPlayerHere", function (room :RoomSubControlServer) :Function {
            return room.isPlayerHere;
        }, [new Parameter("id", int)]);

        room.addMethod("getAvatarInfo", function (room :RoomSubControlServer) :Function {
            return room.getAvatarInfo;
        }, [new Parameter("playerId", int)]);

        room.addMethod("getRoomBounds", function (room :RoomSubControlServer) :Function {
            return room.getRoomBounds;
        });

        room.addMethod("spawnMob", function (room :RoomSubControlServer) :Function {
            return room.spawnMob;
        }, [new Parameter("id", String),
            new Parameter("name", String),
            new Parameter("x", Number),
            new Parameter("y", Number), 
            new Parameter("z", Number)]);

        room.addMethod("despawnMob", function (room :RoomSubControlServer) :Function {
            return room.despawnMob;
        }, [new Parameter("id", String)]);

        room.addMethod("getSpawnedMobs", function (room :RoomSubControlServer) :Function {
            return room.getSpawnedMobs;
        });

        room.addMethod("sendMessage", function (room :RoomSubControlServer) :Function {
            return room.sendMessage;
        }, [new Parameter("name", String),
            new ObjectParameter("value")]);

        room.addMethod("sendSignal", function (room :RoomSubControlServer) :Function {
            return room.sendSignal;
        }, [new Parameter("name", String),
            new ObjectParameter("value")]);

        var funcs :Array = room.toSpecs();

        pushPropsFuncs(funcs, "room", function (id :int) :PropertySubControl {
            return _ctrl.getRoom(id).props;
        });

        return funcs;
    }

    protected function createPlayerFuncs () :Array
    {
        var player :TargetedSubCtrlDef = new TargetedSubCtrlDef(
            _ctrl.getPlayer, new Parameter("playerId", int));

        player.addMethod("getPlayerId", function (props :PlayerSubControlServer) :Function {
            return props.getPlayerId;
        });

        player.addMethod("getRoomId", function (props :PlayerSubControlServer) :Function {
            return props.getRoomId;
        });

        player.addMethod("holdsTrophy", function (props :PlayerSubControlServer) :Function {
            return props.holdsTrophy;
        }, [new Parameter("ident", String)]);

        player.addMethod("awardTrophy", function (props :PlayerSubControlServer) :Function {
            return props.awardTrophy;
        }, [new Parameter("ident", String)]);

        player.addMethod("awardPrize", function (props :PlayerSubControlServer) :Function {
            return props.awardPrize;
        }, [new Parameter("ident", String)]);

        player.addMethod("getPlayerItemPacks", function (props :PlayerSubControlServer) :Function {
            return props.getPlayerItemPacks;
        });

        player.addMethod("getPlayerLevelPacks", function (props :PlayerSubControlServer) :Function {
            return props.getPlayerLevelPacks;
        });

        player.addMethod("deactivateGame", function (props :PlayerSubControlServer) :Function {
            return props.deactivateGame;
        });

        player.addMethod("completeTask", function (props :PlayerSubControlServer) :Function {
            return props.completeTask;
        }, [new Parameter("taskId", String),
            new Parameter("payout", Number)]);

        player.addMethod("playAvatarAction", function (props :PlayerSubControlServer) :Function {
            return props.playAvatarAction;
        }, [new Parameter("action", String)]);

        player.addMethod("setAvatarState", function (props :PlayerSubControlServer) :Function {
            return props.setAvatarState;
        }, [new Parameter("state", String)]);

        player.addMethod("setAvatarMoveSpeed", function (props :PlayerSubControlServer) :Function {
            return props.setAvatarMoveSpeed;
        }, [new Parameter("pixelsPerSecond", Number)]);

        player.addMethod("setAvatarLocation", function (props :PlayerSubControlServer) :Function {
            return props.setAvatarLocation;
        }, [new Parameter("x", Number),
            new Parameter("y", Number),
            new Parameter("z", Number),
            new Parameter("orient", Number)]);

        player.addMethod("setAvatarOrientation", function (props :PlayerSubControlServer) :Function {
            return props.setAvatarOrientation;
        }, [new Parameter("orient", Number)]);

        player.addMethod("sendMessage", function (props :PlayerSubControlServer) :Function {
            return props.sendMessage;
        }, [new Parameter("name", String),
            new ObjectParameter("value")]);

        var funcs :Array = player.toSpecs();

        pushPropsFuncs(funcs, "player", function (id :int) :PropertySubControl {
            return _ctrl.getPlayer(id).props;
        });

        return funcs;
    }

    protected function createMobFuncs () :Array
    {
        var room :TargetedSubCtrlDef = new TargetedSubCtrlDef(
            _ctrl.getRoom, new Parameter("roomId", int));

        var mobIdParam :Parameter = new Parameter("mobId", String);

        room.addMethod("moveTo", function (ctrl :RoomSubControlServer) :Function {
            return function (mobId :String, ...args) :* {
                return ctrl.getMobSubControl(mobId).moveTo.apply(null, args);
            }
        }, [mobIdParam,
            new Parameter("x", Number),
            new Parameter("y", Number),
            new Parameter("z", Number)]);

        return room.toSpecs();
    }

    protected function createMiscFuncs () :Array
    {
        return [
            new FunctionSpec("dump", dump, [])
        ];
    }

    protected function pushPropsFuncs (
        funcs :Array, targetName :String, instanceGetter :Function) :void
    {
        var props :TargetedSubCtrlDef = new TargetedSubCtrlDef(
            instanceGetter, new Parameter(targetName + "Id", int));

        props.addMethod("props.get", function (props :PropertyGetSubControl) :Function {
            return props.get;
        }, [new Parameter("propName", String)]);

        props.addMethod("props.getPropertyNames", function (props :PropertyGetSubControl) :Function {
            return props.getPropertyNames;
        }, [new Parameter("prefix", String, Parameter.OPTIONAL)]);

        props.addMethod("props.set", function (props: PropertySubControl) :Function {
            return props.set;
        }, [new Parameter("propName", String),
            new ObjectParameter("value", Parameter.NULLABLE),
            new Parameter("immediate", Boolean, Parameter.OPTIONAL)]);

        props.addMethod("props.setAt", function (props: PropertySubControl) :Function {
            return props.setAt;
        }, [new Parameter("propName", String),
            new Parameter("index", int),
            new ObjectParameter("value", Parameter.NULLABLE),
            new Parameter("immediate", Boolean, Parameter.OPTIONAL)]);

        props.addMethod("props.setIn", function (props: PropertySubControl) :Function {
            return props.setIn;
        }, [new Parameter("propName", String),
            new Parameter("key", int),
            new ObjectParameter("value", Parameter.NULLABLE),
            new Parameter("immediate", Boolean, Parameter.OPTIONAL)]);

        funcs.push.apply(null, props.toSpecs());
    }

    protected var _ctrl :AVRServerGameControl;
    protected var _funcs :Object = {};
}

}
