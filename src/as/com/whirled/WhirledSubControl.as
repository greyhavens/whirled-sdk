//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.errors.IllegalOperationError;

import flash.events.EventDispatcher;

/**
 * Abstract base class. Do not instantiate.
 */
public class WhirledSubControl extends EventDispatcher
{
    public function WhirledSubControl (ctrl :WhirledControl)
    {
        super();
        if (ctrl == null || Object(this).constructor == WhirledSubControl) {
            throw new IllegalOperationError("Abstract");
        }

        _ctrl = ctrl;
    }

    protected var _ctrl :WhirledControl;
}
}

