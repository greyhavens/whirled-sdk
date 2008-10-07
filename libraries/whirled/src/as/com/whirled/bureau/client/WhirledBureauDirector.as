//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import com.threerings.bureau.data.AgentObject;
import com.threerings.bureau.client.Agent;
import com.threerings.bureau.client.BureauDirector;
import com.whirled.bureau.data.GameAgentObject;
import com.whirled.bureau.util.WhirledBureauContext;

/** Implements the bureau director for whirled. Creates our whirled agent types. */
public class WhirledBureauDirector extends BureauDirector
{
    /** Creates a new director. */
    public function WhirledBureauDirector (ctx :WhirledBureauContext)
    {
        super(ctx);
    }

    // from BureauDirector
    protected override function createAgent (agentObj :AgentObject) :Agent
    {
        if (agentObj is GameAgentObject) {
            return new WhirledGameAgent(_ctx as WhirledBureauContext);
        }

        throw new Error("Unknown type");
    }
}

}
