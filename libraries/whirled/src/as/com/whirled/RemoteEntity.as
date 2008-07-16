package com.whirled {

import com.whirled.EntityControl;

/**
 * A helper proxy for accessing properties of another entity in the room.
 */
public class RemoteEntity
{
    public static const TYPE_FURNI :String = "furni"; // encompasses furni, decor and toys
    public static const TYPE_AVATAR :String = "avatar";
    public static const TYPE_PET :String = "pet";

    /**
     * The entity's location in logical coordinates (an Array [ x, y, z ]). x, y, and z are Numbers
     * between 0 and 1 or null if our location is unknown. Use with getEntityProperty().
     */
    public static const PROP_LOCATION_LOGICAL :String = "std:location_logical";

    /**
     * The entity's location in pixel coordinates (an Array [ x, y, z ]). Obviously there is not a
     * real Z coordinate, but the value will coorrespond to real Z distance in proportion to the
     * distance in X and Y. Use with getEntityProperty().
     */
    public static const PROP_LOCATION_PIXEL :String = "std:location_pixel";

    /** The entity's hot spot (an Array [x, y]). Use with getEntityProperty(). */
    public static const PROP_HOTSPOT :String = "std:hotspot";

    /** The entity pixel dimensions (an Array [width, height]). Use with getEntityProperty(). */
    public static const PROP_DIMENSIONS :String = "std:dimensions";

    /** The entity facing direction (a Number). Use with getEntityProperty(). */
    public static const PROP_ORIENTATION :String = "std:orientation";

    /**
     * The non-unique display name of the entity for avatars and pets.
     * Invalid entity types will return null. Use with getEntityProperty().
     */
    public static const PROP_NAME :String = "std:name";

    /**
     * The unique Whirled player ID of the owner on an avatar.
     * Querying this on non-avatars returns null. Use with getEntityProperty().
     */
    public static const PROP_MEMBER_ID :String = "std:member_id";


    public function RemoteEntity (ctrl :EntityControl, entityId :String)
    {
        _ctrl = ctrl;
        _entityId = entityId;
    }

    public function get (key :String) :Object
    {
        return _ctrl.getEntityProperty(key, _entityId);
    }

    public function call (key :String, ... args) :Object
    {
        var callback :Function = get(key) as Function;
        return (callback == null) ? null : callback.call(null, args);
    }

    /**
     * The entity's location in logical coordinates (an Array [ x, y, z ]). x, y, and z are Numbers
     * between 0 and 1 or null if our location is unknown.
     */
    public function getLogicalLocation () :Array
    {
        return get(PROP_LOCATION_LOGICAL) as Array;
    }

    /**
     * The entity's location in pixel coordinates (an Array [ x, y, z ]). Obviously there is not a
     * real Z coordinate, but the value will coorrespond to real Z distance in proportion to the
     * distance in X and Y.
     */
    public function getPixelLocation () :Array
    {
        return get(PROP_LOCATION_PIXEL) as Array;
    }

    /** The entity's hot spot (an Array [x, y]). */
    public function getHotspot () :Array
    {
        return get(PROP_HOTSPOT) as Array;
    }

    /** The entity pixel dimensions (an Array [width, height]). */
    public function getDimensions () :Array
    {
        return get(PROP_DIMENSIONS) as Array;
    }

    /** The entity facing direction. */
    public function getOrientation () :Number
    {
        return get(PROP_ORIENTATION) as Number;
    }

    /**
     * The non-unique display name of the entity for avatars and pets.
     * Invalid entity types will return null.
     */
    public function getName () :String
    {
        return get(PROP_NAME) as String;
    }

    /**
     * The unique Whirled player ID of the owner on an avatar.
     * Querying this on non-avatars returns zero.
     */
    public function getMemberId () :int
    {
        return get(PROP_MEMBER_ID) as int;
    }

    protected var _ctrl :EntityControl;
    protected var _entityId :String;
}

}
