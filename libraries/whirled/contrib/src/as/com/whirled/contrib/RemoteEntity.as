package com.whirled.contrib {

import com.whirled.EntityControl;

/**
 * A helper proxy for accessing properties of another entity in the room.
 *
 * @example
 * <listing version="3.0">
 * var remote :RemoteEntity = new RemoteEntity(_ctrl, someTargetId);
 * if (remote.get("apples") < remote.get("oranges")) {
 *     trace("Giving a couple dozen apples to " + remote.getName());
 *     remote.call("bobForApples", 24);
 * }
 * </listing>
 */
public class RemoteEntity
{
    public function RemoteEntity (ctrl :EntityControl, entityId :String)
    {
        _ctrl = ctrl;
        _entityId = entityId;
    }

    /** Request a property from the entity. */
    public function get (key :String) :Object
    {
        return _ctrl.getEntityProperty(key, _entityId);
    }

    /**
     * Request a Function from the entity and call it.
     * @return The result of the function call or undefined if the function is unavailable.
     */
    public function call (key :String, ... args) :*
    {
        var callback :Function = get(key) as Function;
        return (callback == null) ? undefined : callback.call(null, args);
    }

    /** @see EntityControl#PROP_LOCATION_LOGICAL */
    public function getLogicalLocation () :Array
    {
        return get(EntityControl.PROP_LOCATION_LOGICAL) as Array;
    }

    /** @see EntityControl#PROP_LOCATION_PIXEL */
    public function getPixelLocation () :Array
    {
        return get(EntityControl.PROP_LOCATION_PIXEL) as Array;
    }

    /** @see EntityControl#PROP_HOTSPOT */
    public function getHotspot () :Array
    {
        return get(EntityControl.PROP_HOTSPOT) as Array;
    }

    /** @see EntityControl#PROP_DIMENSIONS */
    public function getDimensions () :Array
    {
        return get(EntityControl.PROP_DIMENSIONS) as Array;
    }

    /** @see EntityControl#PROP_ORIENTATION */
    public function getOrientation () :Number
    {
        return get(EntityControl.PROP_ORIENTATION) as Number;
    }

    /** @see EntityControl#PROP_NAME */
    public function getName () :String
    {
        return get(EntityControl.PROP_NAME) as String;
    }

    /** @see EntityControl#PROP_MEMBER_ID */
    public function getMemberId () :int
    {
        return get(EntityControl.PROP_MEMBER_ID) as int;
    }

    /** Your code's EntityControl. */
    protected var _ctrl :EntityControl;

    /** The unique identifier of this entity. */
    protected var _entityId :String;
}

}
