//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.server;

import com.threerings.presents.data.ClientObject;

import com.threerings.crowd.server.CrowdClientResolver;

import com.whirled.data.WhirledBodyObject;

/**
 * Used to configure whirled test server specific client object data.
 */
public class WhirledTestClientResolver extends CrowdClientResolver
{
    @Override
    public ClientObject createClientObject ()
    {
        return new WhirledBodyObject();
    }
}
