//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TextEvent;

/**
 * This file should be included by furniture, so that it can communicate
 * with the whirled.
 */
public class FurniControl extends EntityControl
{
    /** An action triggered when someone arrives at the location at which
     * this furniture is placed, if this piece of furniture is a doorway. */
    public static const BODY_ENTERED :String = "bodyEntered";

    /** An action triggered when someone leaves via this piece of doorway
     * furniture. */
    public static const BODY_LEFT :String = "bodyLeft";

    /**
     * Create a furni interface. The display object is your piece
     * of furni.
     */
    public function FurniControl (disp :DisplayObject)
    {
        super(disp);
    }

    override protected function isAbstract () :Boolean
    {
        return false;
    }
}
}
