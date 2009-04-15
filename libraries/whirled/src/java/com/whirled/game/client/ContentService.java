//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

import com.whirled.game.data.WhirledPlayerObject;
import com.whirled.game.data.GameContentOwnership;

/**
 * Handles content-related game services.
 */
public interface ContentService extends InvocationService
{
    /**
     * Requests to consume the specified item pack. If the request is processed, the client will
     * see count-reduction in or removal of the appropriate {@link GameContentOwnership} record in
     * the requesting player's {@link WhirledPlayerObject#gameContent} set.
     */
    public void consumeItemPack (Client client, String ident, InvocationListener listener);
}
