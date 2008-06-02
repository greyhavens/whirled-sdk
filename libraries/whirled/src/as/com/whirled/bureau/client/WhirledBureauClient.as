//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import com.threerings.bureau.client.BureauClient;
import com.threerings.bureau.client.BureauDirector;
import com.threerings.bureau.Log;

/** The bureau client for whirled. */
public class WhirledBureauClient extends BureauClient
{
    /**
     * Launches a new client from command line (String) arguments. 
     * @param argv array of command line arguments: (bureauId) (token) (port)
     * @param version for authenticaion, the deployment version
     */
    public static function main (args :Array, version :String="0") :void
    {
        var bureauId :String = args[0];
        var token :String = args[1];
        var server :String = "localhost";
        var port :int = parseInt(args[2]);

        Log.info(
            "Starting client with token=" + token + 
            ", bureauId=" + bureauId + 
            ", server=" + server + 
            ", port=" + port);

        // create the client and log on
        var client :WhirledBureauClient = new WhirledBureauClient(token, bureauId);
        client.setVersion(version);
        client.setServer(server, [port]);
        client.logon();
    }

    /** Creates a new client. */
    public function WhirledBureauClient (token :String, bureauId :String)
    {
        super(token, bureauId);
    }

    // from BureauClient
    protected override function createDirector () :BureauDirector
    {
        return new WhirledBureauDirector(_ctx);
    }
}

}

