//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import com.threerings.bureau.client.BureauClient;
import com.threerings.bureau.client.BureauDirector;
import com.threerings.bureau.util.BureauContext;
import com.threerings.bureau.Log;
import com.whirled.bureau.util.WhirledBureauContext;

/** The bureau client for whirled. */
public class WhirledBureauClient extends BureauClient
{
    /**
     * Launches a new client from command line (String) arguments. 
     * @param argv array of command line arguments: (bureauId) (token) (port)
     * @param version for authenticaion, the deployment version
     */
    public static function main (
        args :Array, 
        version :String, 
        userCodeLoader :UserCodeLoader=null) :void
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
        var client :WhirledBureauClient = new WhirledBureauClient(
            token, bureauId, userCodeLoader);
        client.setVersion(version);
        client.setServer(server, [port]);
        client.logon();
    }

    /** Creates a new client. */
    public function WhirledBureauClient (
        token :String, 
        bureauId :String,
        userCodeLoader :UserCodeLoader)
    {
        super(token, bureauId);
        _userCodeLoader = userCodeLoader;
    }

    public function getUserCodeLoader () :UserCodeLoader
    {
        return _userCodeLoader;
    }

    // from BureauClient
    protected override function createDirector () :BureauDirector
    {
        return new WhirledBureauDirector(_ctx as WhirledBureauContext);
    }

    // from BureauClient
    protected override function createContext () :BureauContext
    {
        return new ContextImpl(this);
    }

    protected var _userCodeLoader :UserCodeLoader;
}

}

import com.threerings.bureau.client.BureauDirector;
import com.whirled.bureau.client.WhirledBureauClient;
import com.whirled.bureau.util.WhirledBureauContext;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.client.Client;
import com.whirled.bureau.client.UserCodeLoader;

class ContextImpl
    implements WhirledBureauContext
{
    function ContextImpl (client :WhirledBureauClient)
    {
        _client = client;
    }

    public function getBureauDirector () :BureauDirector
    {
        return _client.getBureauDirector();
    }

    public function getDObjectManager () :DObjectManager
    {
        return _client.getDObjectManager();
    }

    public function getClient () :Client
    {
        return _client;
    }

    public function getBureauId () :String
    {
        return _client.getBureauId();
    }

    public function getUserCodeLoader () :UserCodeLoader
    {
        return _client.getUserCodeLoader();
    }

    protected var _client :WhirledBureauClient;
}
