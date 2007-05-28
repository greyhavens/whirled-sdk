//
// $Id$

package com.whirled.server;

import com.threerings.presents.client.Client;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;
import com.whirled.client.TestService;

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
