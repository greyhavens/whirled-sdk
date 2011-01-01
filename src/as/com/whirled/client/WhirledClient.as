//
// $Id$
//
// Copyright (c) 2007-2011 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.client {

import flash.display.Stage;
import flash.display.StageQuality;

import flash.system.Security;

import mx.resources.ResourceBundle;

import com.threerings.util.Log;
import com.threerings.util.Name;

import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.TimeBaseMarshaller;
import com.threerings.presents.net.Credentials;
import com.threerings.presents.net.UsernamePasswordCreds;

import com.threerings.crowd.chat.data.ChatMarshaller;
import com.threerings.crowd.client.CrowdClient;
import com.threerings.crowd.data.BodyMarshaller;
import com.threerings.crowd.data.LocationMarshaller;

import com.threerings.parlor.data.ParlorMarshaller;
import com.threerings.parlor.game.data.UserIdentifier;

import com.whirled.game.client.TestGameController;
import com.whirled.game.client.TestService;
import com.whirled.game.client.TestUserIdentifier;
import com.whirled.game.data.TestGameDefinition;
import com.whirled.game.data.TestMarshaller;
import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.data.WhirledPlayerObject;

/**
 * A client used for testing games.
 */
public class WhirledClient extends CrowdClient
{
    public static const log :Log = Log.getLog(WhirledClient);

    public function WhirledClient (stage :Stage)
    {
        var username :String = stage.loaderInfo.parameters["username"] as String;
        if (username == null) {
            username = "tester";
        }
        super(new UsernamePasswordCreds(new Name(username), ""));
        _ctx = createContext(stage);

        // set the quality to MEDIUM, just like it is in whirled.
        stage.quality = StageQuality.MEDIUM;

        // set up the user identifier
        UserIdentifier.setIder(TestUserIdentifier.getUserId);

        // prior to logging on to a server, set up our security policy for that server
        addClientObserver(new ClientAdapter(clientWillLogon)); 

        setServer("localhost", DEFAULT_SERVER_PORTS);
        logon();
    }

    public function fuckingCompiler () :void
    {
        var i :int = TimeBaseMarshaller.GET_TIME_OID;
        i = LocationMarshaller.LEAVE_PLACE;
        i = BodyMarshaller.SET_IDLE;
        i = ChatMarshaller.AWAY;

        var c :Class;
        c = ParlorMarshaller;
        c = TestMarshaller;
        c = WhirledGameConfig;
        c = TestGameDefinition;
        c = TestGameController;
        c = WhirledPlayerObject;

        [ResourceBundle("global")]
        [ResourceBundle("chat")]
        var rb :ResourceBundle;
    }

    // from Client
    override public function gotClientObject (clobj :ClientObject) :void
    {
        super.gotClientObject(clobj);

        // let the server know we're ready to play
        (_ctx.getClient().requireService(TestService) as TestService).clientReady();
    }

    /**
     * Creates the context we'll use with this client.
     */
    protected function createContext (stage :Stage) :WhirledContext
    {
        return new WhirledContext(this, stage);
    }

    /**
     * Called just before we logon to a server.
     */
    protected function clientWillLogon (event :ClientEvent) :void
    {
        var url :String = "xmlsocket://localhost:47623";
        log.info("Loading security policy: " + url);
        Security.loadPolicyFile(url);
    }

    protected var _ctx :WhirledContext;
}
}
