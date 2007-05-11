//
// $Id$

package com.whirled.server;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;
import com.whirled.client.WhirledGameService;

/**
 * Defines the server-side of the {@link WhirledGameService}.
 */
public interface WhirledGameProvider extends InvocationProvider
{
    /**
     * Handles a {@link WhirledGameService#awardFlow} request.
     */
    public void awardFlow (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;
}
