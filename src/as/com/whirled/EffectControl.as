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
 * This file should be included by effects.
 * There are currently no such thing as effects.
 * @private
 */
public class EffectControl extends EntityControl
{
    /**
     * Create a effect control.
     */
    public function EffectControl (disp :DisplayObject)
    {
        super(disp);
    }

    /**
     * Return the "parameters" (really just one unparsed String) for this effect, if any.
     */
    public function getParameters () :String
    {
        return _params;
    }

    /**
     * Called to notify the host that this effect animation is done.
     */
    public function effectFinished () :void
    {
        sendMessage("effectFinished");
    }

    // from WhirledControl
    override protected function gotInitProperties (o :Object) :void
    {
        super.gotInitProperties(o);

        _params = (o["parameters"] as String);
    }

    override protected function isAbstract () :Boolean
    {
        return false;
    }

    /** Our parameters, if any. */
    protected var _params :String;
}
}
