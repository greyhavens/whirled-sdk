//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

/**
 * Dispatched when the control has been resized.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.SIZE_CHANGED
 */
[Event(name="sizeChanged", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Defines actions, accessors and callbacks available on the client only.
 */
public class ClientSubControl extends AbstractSubControl
{
    /** @private */
    public function ClientSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    /**
     * Returns the bounds of the "stage" on which the AVRG will be drawn.
     * This value changes when the browser is resized, and when the player moves to another room.
     *
     * @param full If true (the default), return the entire paintable area. If false,
     * return the area occupied by the room's decor, which can be smaller than the entire
     * paintable area in narrow rooms, or when the room view is zoomed out.
     *
     * @return a Rectangle containing the stage bounds
     */
    public function getStageSize (full :Boolean = true) :Rectangle
    {
        return Rectangle(callHostCode("getStageSize_v1", full));
    }

    /**
     * Get the room's bounds in pixel coordinates. This is essentially the width and height
     * of the room's decor. It is an absolute coordinate system, i.e. (x, y) for one client
     * here is the same (x, y) as for another.
     *
     * @return a Rectangle anchored at (0, 0)
     */
    public function getRoomBounds () :Rectangle
    {
        return callHostCode("getRoomBounds_v1") as Rectangle;
    }

    public function stageToRoom (p :Point) :Point
    {
        return callHostCode("stageToRoom_v1", p) as Point;
    }

    public function roomToStage (p :Point) :Point
    {
        return callHostCode("roomToStage_v1", p) as Point;
    }

    public function locationToRoom (x :Number, y :Number, z :Number) :Point
    {
        return callHostCode("locationToRoom_v1", x, y, z) as Point;
    }

    public function locationToStage (x :Number, y :Number, z :Number) :Point
    {
        var roomCoord :Point = locationToRoom(x, y, z);
        if (null != roomCoord) {
            return roomToStage(roomCoord);
        }

        return null;
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["panelResized_v1"] = panelResized_v1;
    }

    /** @private */
    protected function panelResized_v1 () :void
    {
        dispatch(new AVRGameControlEvent(AVRGameControlEvent.SIZE_CHANGED));
    }
}
}
