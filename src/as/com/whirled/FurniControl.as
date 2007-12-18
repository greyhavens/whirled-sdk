//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

import flash.events.Event;
import flash.events.EventDispatcher;

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

    /**
     * Register a function used for generating a custom config panel. This will
     * be called when this piece of furniture is being edited inside whirled.
     *
     * @param func signature: function () :DisplayObject
     * Your function should return a DisplayObject as a configuration panel.
     * The width/height of the object at return time will be used to configure the amount
     * of space given it. Any changes made by the user should effect immediately, or
     * you should provide buttons to apply the change, if absolutely necessary.
     */
    public function registerCustomConfig (func :Function) :void
    {
        _customConfig = func;
    }

    override protected function isAbstract () :Boolean
    {
        return false;
    }

    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        o["getConfigPanel_v1"] = getConfigPanel_v1;
    }

    /**
     * Called when whirled is editing this furniture, to retrieve any custom configuration
     * panel.
     */
    protected function getConfigPanel_v1 () :DisplayObject
    {
        return (_customConfig != null) ? (_customConfig() as DisplayObject) : null;
    }

    /** A function registered to return a custom configuration panel. */
    protected var _customConfig :Function;
}
}
