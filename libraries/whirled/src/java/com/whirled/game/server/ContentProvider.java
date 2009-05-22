//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;
import com.whirled.game.client.ContentService;

/**
 * Defines the server-side of the {@link ContentService}.
 */
public interface ContentProvider extends InvocationProvider
{
    /**
     * Handles a {@link ContentService#consumeItemPack} request.
     */
    void consumeItemPack (ClientObject caller, int arg1, String arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;
}
