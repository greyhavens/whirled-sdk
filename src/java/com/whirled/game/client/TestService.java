//
// $Id$

package com.whirled.game.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

/**
 * Used for testing Flash games.
 */
public interface TestService extends InvocationService
{
    /** Informs the server that this client is ready to start. */
    public void clientReady (Client client);
}
