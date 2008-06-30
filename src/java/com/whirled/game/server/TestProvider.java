//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link TestService}.
 */
public interface TestProvider extends InvocationProvider
{
    /**
     * Handles a {@link TestService#clientReady} request.
     */
    public void clientReady (ClientObject caller);
}
