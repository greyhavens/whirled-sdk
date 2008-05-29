//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import com.threerings.bureau.data.AgentObject;
import com.threerings.bureau.client.Agent;
import com.threerings.bureau.client.BureauDirector;
import com.threerings.bureau.util.BureauContext;
import com.whirled.bureau.data.GameAgentObject;

/** Implements the bureau director for whirled. Creates our whirled agent types. */
public class WhirledBureauDirector extends BureauDirector
{
    /** Creates a new director. */
    public function WhirledBureauDirector (ctx :BureauContext)
    {
        super(ctx);
    }

    // from BureauDirector
    protected override function createAgent (agentObj :AgentObject) :Agent
    {
        if (agentObj is GameAgentObject) {
            return new GameAgent(_ctx as BureauContext);
        }

        throw new Error("Unknown type");
    }
}

}
