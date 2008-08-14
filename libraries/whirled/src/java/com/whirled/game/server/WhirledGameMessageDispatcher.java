//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;
import com.whirled.game.data.WhirledGameMessageMarshaller;

/**
 * Dispatches requests to the {@link WhirledGameMessageProvider}.
 */
public class WhirledGameMessageDispatcher extends InvocationDispatcher<WhirledGameMessageMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public WhirledGameMessageDispatcher (WhirledGameMessageProvider provider)
    {
        this.provider = provider;
    }

    @Override // documentation inherited
    public WhirledGameMessageMarshaller createMarshaller ()
    {
        return new WhirledGameMessageMarshaller();
    }

    @Override // documentation inherited
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case WhirledGameMessageMarshaller.SEND_MESSAGE:
            ((WhirledGameMessageProvider)provider).sendMessage(
                source, (String)args[0], args[1], ((Integer)args[2]).intValue(), ((Integer)args[3]).intValue(), (InvocationService.InvocationListener)args[4]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
