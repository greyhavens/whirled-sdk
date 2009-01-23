//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;
import com.whirled.game.data.TestMarshaller;

/**
 * Dispatches requests to the {@link TestProvider}.
 */
public class TestDispatcher extends InvocationDispatcher<TestMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public TestDispatcher (TestProvider provider)
    {
        this.provider = provider;
    }

    @Override // documentation inherited
    public TestMarshaller createMarshaller ()
    {
        return new TestMarshaller();
    }

    @Override // documentation inherited
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case TestMarshaller.CLIENT_READY:
            ((TestProvider)provider).clientReady(
                source
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
