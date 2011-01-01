//
// $Id$
//
// Copyright (c) 2007-2011 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.presents.client.InvocationService;

/**
 * An ActionScript version of the Java TestService interface.
 */
public interface TestService extends InvocationService
{
    // from Java interface TestService
    function clientReady () :void;
}
}
