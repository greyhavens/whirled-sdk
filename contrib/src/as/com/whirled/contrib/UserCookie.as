// $Id$

package com.whirled.contrib {

import flash.errors.IllegalOperationError;

import flash.events.TimerEvent;

import flash.utils.ByteArray;
import flash.utils.Timer;

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.whirled.WhirledGameControl;

/**
 * <p>A class to manage complicated user cookies on a WhirledGameControl.  Using this class, user 
 * cookies can contain a list of various different data types, which are read from the server and
 * saved back to the server automatically.  The data structure is compressed into a ByteArray to 
 * save space (user cookies are only allowed to go up to 4k).  Data is saved to the server as it is
 * updated on this object, but no faster than once per every 2 seconds so that this class doesn't 
 * add too much to the game's networking activity, as games are limited to 100 messages per every 
 * 10 seconds.</p>
 * 
 * <p>This class enables versioning, up to a point.  It currently supports adding parameters to the 
 * cookie definition, but does not support removing them or changing their data type.  The only
 * overhead added by this class to the cookie itself is a single int that holds the version number
 * of the cookie.</p>
 *
 * <p>example usage:  This could be used for a game that has 5 levels.  At first the developer only
 * needed to know which was the last level the player played on, so it was stored in the cookie.  
 * Later he wanted to know how many times each level had been played by the player, so he added it
 * to the cookie definition in a new version.</p>
 *
 * <pre>
 * protected var LAST_LEVEL_PLAYED :String = "lastLevelPlayed";
 * protected var TIMES_LEVELS_PLAYED :String = "timesLevelsPlayed";
 * 
 * public function getCookie () :void 
 * {
 *     var timesPlayed :Array = [];
 *     for (level = 0; level < 5; level++) {
 *         // parameter names are not used if the parameter is nested in an array.  Arrays can also 
 *         // hold array parameters as children.
 *         timesPlayed.push(UserCookie.getIntParameter("", 0));
 *     }
 * 
 *     var cookieDef :Array = [
 *         // start at version 1
 *         UserCookie.getVersionParameter(),
 *         UserCookie.getIntParameter(LAST_LEVEL_PLAYED, 0),
 *     
 *         // version 2 added the number of times each level was played
 *         UserCookie.getVersionParameter(),
 *         UserCookie.getArrayParameter(TIMES_LEVELS_PLAYED, timesPlayed)
 *     ];
 *     
 *     UserCookie.getCookie(wgc, function (cookie :UserCookie) :void {
 *         // notify those that need to know that the UserCookie is valid and available.
 *         _cookie = cookie;
 *     }, cookieDef);
 * }
 * 
 * public function setLastLevelPlayed (level :int) :void
 * {
 *     if (_cookie != null) {
 *         _cookie.set(LAST_LEVEL_PLAYED, level);
 *     }
 * }
 * 
 * public function playedLevel (level :int) :void
 * {
 *     if (_cookie != null) {
 *         // increment the array value for this level.
 *         var previousValue :int = _cookie.get(TIMES_LEVELS_PLAYED, level);     
 *         _cookie.set(TIMES_LEVELS_PLAYED, previousValue + 1, level);
 *     }
 * }
 * </pre>
 */
public class UserCookie
{
    /**
     * Get a player's user cookie via WhirledGameControl.getUserCookie, wrapped in a UserCookie
     * object.
     * 
     * @param wgc The WhirledGameControl of the current instance
     * @param validCallback This function is called with a single UserCookie parameter when the
     *                      cookie has been retrieved and validated.
     * @param cookieDef An array of cookie parameters that define the format of the user cookie.  
     *                  See the various get*Parameter() functions for more detail.
     * @param enableDebugLogging Enable logging of some debug messages, including the values read
     *                           out of the user cookie in the initial read.  Logging is done via
     *                           com.threerings.util.Log.
     * @param occId The player's id to fetch the cookie for.  Defaults to the current player.  If
     *              a different player is specified, this UserCookie will be read-only - attempting
     *              to set a value will generate an IllegalOperationError.
     */
    public static function getCookie (wgc :WhirledGameControl, validCallback :Function, 
        cookieDef :Array, enableDebugLogging :Boolean = false, occId :int = -1) :void
    {
        var cookie :UserCookie = new UserCookie();
        cookie._control = wgc;
        cookie._cookieDef = cookieDef;
        cookie._readOnly = occId != -1 && occId != wgc.getMyId();
        cookie._logDebug = enableDebugLogging;
        wgc.getUserCookie(occId == -1 ? wgc.getMyId() : occId, function (obj :Object) :void {
            if (obj is ByteArray) {
                cookie.read(obj as ByteArray);
            } else {
                log.warning("Unknown cookie object type or cookie not found, using defaults");
                cookie.read(null);
            }
            validCallback(cookie);
        });
    }

    /**
     * Returns an int typped parameter for use in the cookieDef argument to getCookie().
     */
    public static function getIntParameter (name :String, defaultValue :int) :CookieParameter
    {
        return new CookieParameter(name, int, defaultValue);
    }

    /**
     * Returns a String typped parameter for use in the cookieDef argument to getCookie().
     */
    public static function getStringParameter (name :String, defaultValue :String) :CookieParameter
    {
        return new CookieParameter(name, String, defaultValue);
    }

    /**
     * Returns an Array typped parameter for use in the cookieDef argument to getCookie().  All of
     * the children must be CookieParameters returned from a get*Parameter() function, or an 
     * ArgumentError will be thrown.  Also, you cannot embed a version in an array.
     */
    public static function getArrayParameter (name :String, children :Array) :CookieParameter
    {
        return new ArrayParameter(name, children);
    }

    /**
     * Returns a version flag for use in the cookieDef argument to getCookie().  If the cookie 
     * definition for a game is extended after some players may have the old cookie already set,
     * there should be a version flag added before adding in the new parameters.  This will allow
     * the old players to gracefully add in the new values when they play the game again.
     * 
     * If a player with an old cookie or no cookie plays the game, each parameter will return
     * its default type.  The default type will also get set for this player on the server until
     * a new value is defined.
     */
    public static function getVersionParameter () :CookieParameter
    {
        return new VersionParameter();
    }

    /**
     * This function should not be called directly.  Instead, call UserCookie.getCookie().
     */
    public function UserCookie ()
    {
        (_timer = new Timer(SEND_TIME)).addEventListener(TimerEvent.TIMER, flush);
        _timer.start();
    }

    /**
     * Set the value of the cookie parameter identified by name.  If the type of value does not
     * match the type from the cookieDef parameter to getCookie, an ArgumentError is thrown.
     *
     * @param args  The first arg should be the parameter identifier as a String.  The next 
     * argument should be the value to set.  Any further arguments are the array indices to use.  
     * There can be multiple array indices, if a value in a nested array is being set.
     */
    public function set (name :String, value :*, ... indices) :void
    {
        if (_readOnly) {
            throw new IllegalOperationError("Attempted to set a value on a read-only UserCookie");
        }

        var parameter :CookieParameter = _parameters.get(name) as CookieParameter;
        if (parameter == null) {
            throw new ArgumentError("Parameter not found! [" + name + "]");
        }
        if (indices.length == 0) {
            debugLog("setting value [name=" + name + ", value=" + value + "]");
            parameter.value = value;
        } else {
            debugLog("setting array value [name=" + name + ", value=" + value + ", indices=[" + 
                indices + "]]");
            var arrParam :ArrayParameter = parameter as ArrayParameter;
            if (arrParam == null) {
                throw new ArgumentError("Array value setting, but no array found [" + 
                    name + "]");
            }
            setInArray(arrParam, value, indices);
        }

        _dirty = true;
    }

    /**
     * Get the value of the cookie parameter identified by name.  
     * 
     * @param args The first arg should be the parameter identified as a String.  Any further 
     * arguments are the array indices to use.  There can be multiple array indices, if a value
     * in a nested array is being retrieved.
     */
    public function get (name :String, ... indices) :*
    {
        var parameter :CookieParameter = _parameters.get(name) as CookieParameter;
        if (parameter == null) {
            throw new ArgumentError("Parameter not found! [" + name + "]");
        }
        if (indices.length == 0) {
            return parameter.value;
        } else {
            var arrParam :ArrayParameter = parameter as ArrayParameter;
            if (arrParam == null) {
                throw new ArgumentError("Array value requested, but no array found [" +
                    name + "]");
            }
            return getFromArray(arrParam, indices);
        }
    }

    protected function read (bytes :ByteArray) :void
    {
        var version :int = 0;
        if (bytes != null) {
            bytes.uncompress();
            version = bytes.readInt();
            if (version <= 0) {
                throw new ArgumentError("Invalid version number found [" + version + "]");
            }
            debugLog("player's cookie at version [" + version + "]");
        }

        var versionBreak :Boolean = bytes == null;
        for each (var param :CookieParameter in _cookieDef) {
            if (param == null) {
                log.warning("Null cookie param, ignoring and moving on");
                continue;
            }
            
            if (param is VersionParameter) {
                version--;
                if (version < 0) {
                    versionBreak = true;
                }
            } else {
                if (!versionBreak) {
                    param.read(bytes);
                    if (param is ArrayParameter) {
                        debugLog("read param [name=" + param.name + ", children=" + 
                            arrayChildrenAsString(param as ArrayParameter) + "]");
                    } else {
                        debugLog("read param [name=" + param.name + ", value=" + 
                            param.value + "]");
                    }
                } else {
                    if (param is ArrayParameter) {
                        debugLog("param in new version [name=" + param.name + ", children=" +
                            arrayChildrenAsString(param as ArrayParameter) + "]");
                    } else {
                        debugLog("param in new version [name=" + param.name + ", value=" + 
                            param.value + "]");
                    }
                }
                _parameters.put(param.name, param);
            }
        }
    }

    protected function flush (... ignored) :void
    {
        if (_dirty) {
            _control.setUserCookie(write());
            _dirty = false;
        }
    }

    protected function write () :ByteArray
    {
        var bytes :ByteArray = new ByteArray();
        
        // find version number
        var version :int = 0;
        for each (var param :CookieParameter in _cookieDef) {
            if (param is VersionParameter) {
                version++;
            }
        }
        if (version <= 0) {
            throw new ArgumentError("Version must be greater than 0 [" + version + "]");
        }
        bytes.writeInt(version);

        for each (param in _cookieDef) {
            if (param == null) {
                log.warning("Null cookie param, ignoring and moving on");
                continue;
            }
            
            if (param is VersionParameter) {
                // NOOP
                continue;
            } else {
                param.write(bytes);
            }
        }

        bytes.compress();
        debugLog("Writing cookie [size=" + bytes.length + " bytes]");
        return bytes;
    }

    protected function setInArray (array :ArrayParameter, value :*, indices :Array) :void
    {
        var index :int = indices.shift() as int;
        if (isNaN(index) || index < 0 || index > array.children.length - 1) {
            throw new ArgumentError("Array index is not valid [" + index + "]");
        }

        var parameter :CookieParameter = array.children[index] as CookieParameter;
        if (indices.length == 0) {
            parameter.value = value;
        } else {
            if (!(parameter is ArrayParameter)) {
                throw new ArgumentError("Nested array requested, but array not found");
            }
            setInArray(parameter as ArrayParameter, value, indices);
        }
    }

    protected function getFromArray (array :ArrayParameter, indices :Array) :*
    {
        var index :int = indices.shift() as int;
        if (isNaN(index) || index < 0 || index > array.children.length - 1) {
            throw new ArgumentError("Array index is not valid [" + index + "]");
        }

        var parameter :CookieParameter = array.children[index] as CookieParameter;
        if (indices.length == 0) {
            return parameter.value;
        } else {
            if (!(parameter is ArrayParameter)) {
                throw new ArgumentError("Nested array requested, but array not found");
            }
            return getFromArray(parameter as ArrayParameter, indices);
        }
    }

    protected function debugLog (logLine :String) :void
    {
        if (_logDebug) {
            log.debug(logLine);
        }
    }

    protected function arrayChildrenAsString (param :ArrayParameter) :String
    {
        var values :String = "[";
        for each (var parameter :CookieParameter in param.children) {
            if (parameter is ArrayParameter) {
                values += arrayChildrenAsString(parameter as ArrayParameter);
            } else {
                values += "" + parameter.value;
            }

            if (parameter != param.children[param.children.length - 1]) {
                values += ", ";
            }
        }
        values += "]";
        return values;
    }

    private static const log :Log = Log.getLog(UserCookie);

    protected static const SEND_TIME :int = 2 * 1000;

    protected var _control :WhirledGameControl;
    protected var _cookieDef :Array;
    protected var _parameters :HashMap = new HashMap();
    protected var _dirty :Boolean = false;
    protected var _timer :Timer;
    protected var _readOnly :Boolean = false;
    protected var _logDebug :Boolean = false;
}
}

import flash.utils.ByteArray;

import com.threerings.util.Log;

class CookieParameter
{
    public function CookieParameter (name :String, type :Class, defaultValue :*)
    {
        _name = name;        
        _type = type;
        _value = defaultValue;
    }

    public function get name () :String
    {
        return _name;
    }

    public function get type () :Class
    {
        return _type;
    }

    public function get value () :*
    {
        return _value;
    }

    public function set value (v :*) :void
    {
        if (!(v is _type) && v != null) {
            throw new ArgumentError("Setting CookieParameter value with wrong type [" + _type +
                ", " + v + "]");
        }

        _value = v;
    }

    public function read (bytes :ByteArray) :void
    {
        if (_type === int) {
            _value = bytes.readInt();
        } else if (_type === String) {
            _value = bytes.readObject() as String;
        } else {
            throw new ArgumentError("read asked to decode unsupported type [" + _type + "]");
        }
    }

    public function write (bytes :ByteArray) :void
    {
        if (_type === int) {
            bytes.writeInt(_value as int);
        } else if (_type === String) {
            bytes.writeObject(_value as String);
        } else {
            throw new ArgumentError("write asked to encode unsupported type [" + _type + "]");
        }
    }

    private static const log :Log = Log.getLog(CookieParameter);

    protected var _name :String;
    protected var _type :Class;
    protected var _value :*;
}

class VersionParameter extends CookieParameter
{
    public function VersionParameter ()
    {
        super(null, null, null);
    }

    override public function set value (v :*) :void
    {
        throw new ArgumentError("Cannot set value on a VersionParameter");
    }

    override public function read (bytes :ByteArray) :void
    {
        // NOOP
    }

    override public function write (bytes :ByteArray) :void
    {
        // NOOP
    }

    private static const log :Log = Log.getLog(VersionParameter);
}

class ArrayParameter extends CookieParameter
{
    public function ArrayParameter (name :String, children :Array)
    {
        super(name, Array, []);

        for each (var child :CookieParameter in children) {
            if (child == null) {
                throw new ArgumentError("ArrayParameter children must all be CookieParameters");
            }
            if (child is VersionParameter) {
                throw new ArgumentError("ArrayParameter cannot contain a VersionParameter");
            }
        }
        _children = children;
    }

    public function get children () :Array
    {
        return _children;
    }

    override public function set value (v :*) :void
    {
        throw new ArgumentError("ArrayParameter does not support directly setting its value");
    }

    override public function read (bytes :ByteArray) :void
    {
        for each (var child :CookieParameter in children) {
            child.read(bytes);
        }
    }

    override public function write (bytes :ByteArray) :void
    {
        for each (var child :CookieParameter in children) {
            child.write(bytes);
        }
    }

    private static const log :Log = Log.getLog(ArrayParameter);

    protected var _children :Array;
}
