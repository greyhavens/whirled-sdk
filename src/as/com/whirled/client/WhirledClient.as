//
// $Id$

package com.whirled.client {

import flash.display.Stage;

import mx.resources.ResourceBundle;

import com.threerings.util.Name;

import com.threerings.presents.client.Client;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.TimeBaseMarshaller;
import com.threerings.presents.net.Credentials;
import com.threerings.presents.net.UsernamePasswordCreds;

import com.threerings.crowd.chat.data.ChatMarshaller;
import com.threerings.crowd.data.BodyMarshaller;
import com.threerings.crowd.data.LocationMarshaller;

import com.threerings.parlor.data.ParlorMarshaller;
import com.threerings.ezgame.data.EZGameConfig;

import com.whirled.data.TestMarshaller;
import com.whirled.data.WhirledGameDefinition;

/**
 * A client used for testing games.
 */
public class WhirledClient extends Client
{
    public static const log :Log = Log.getLog(WhirledClient);

    public function WhirledClient (stage :Stage)
    {
        var username :String = stage.loaderInfo.parameters["username"] as String;
        if (username == null) {
            username = "tester";
        }
        super(new UsernamePasswordCreds(new Name(username), ""), stage);
        _ctx = createContext();
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
        c = EZGameConfig;
        c = WhirledGameDefinition;
        c = TestGameController;

        [ResourceBundle("global")]
        [ResourceBundle("chat")]
        var rb :ResourceBundle;
    }

    // from Client
    override public function gotClientObject (clobj :ClientObject) :void
    {
        super.gotClientObject(clobj);

        // let the server know we're ready to play
        (_ctx.getClient().requireService(TestService) as TestService).clientReady(_ctx.getClient());
    }

    /**
     * Creates the context we'll use with this client.
     */
    protected function createContext () :WhirledContext
    {
        return new WhirledContext(this);
    }

    protected var _ctx :WhirledContext;
}
}
