//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import flash.geom.Rectangle;

public class AVRGameAvatar
{
    /* The avatar's associated display name. */
    public var name :String;

    /* The avatar's current state. */
    public var state :String;

    /** The avatar's x position. */
    public var x :Number;

    /** The avatar's y position. */
    public var y :Number;

    /** The avatar's z position. */
    public var z :Number;

    /** The avatar's orientation. */
    public var orientation :int;

    /** The avatar's move speed, in pixels per second. */
    public var moveSpeed :Number;

    public var isMoving :Boolean;

    public var isIdle :Boolean;

    public var stageBounds :Rectangle;
}
}
