//
// $Id$

package com.whirled.game.server;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;

import com.samskivert.util.ArrayIntSet;
import com.samskivert.util.ArrayUtil;
import com.samskivert.util.CollectionUtil;
import com.samskivert.util.HashIntMap;
import com.samskivert.util.Interval;
import com.samskivert.util.IntListUtil;
import com.samskivert.util.RandomUtil;
import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

import com.threerings.util.Name;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.AccessController;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.crowd.server.CrowdServer;

import com.threerings.bureau.server.BureauRegistry;

import com.threerings.parlor.game.data.GameConfig;

import com.threerings.parlor.game.server.GameManager;

import com.threerings.parlor.turn.server.TurnGameManager;

import com.threerings.util.MessageBundle;

import com.whirled.game.data.WhirledGameCodes;
import com.whirled.game.data.WhirledGameMarshaller;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledGameOccupantInfo;
import com.whirled.game.data.PropertySetEvent;
import com.whirled.game.data.UserCookie;
import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.data.ThaneGameConfig;
import com.whirled.game.data.GameDefinition;

import com.whirled.bureau.data.GameAgentObject;

import static com.whirled.game.Log.log;

/**
 * A manager for whirled games.
 */
public abstract class WhirledGameManager extends GameManager
    implements WhirledGameCodes, WhirledGameProvider, TurnGameManager
{
    /** Bureau type for launching a thane vm. */
    public static final String THANE_BUREAU = "thane";

    /** The default class name to use for the game agent. */
    public static final String DEFAULT_SERVER_CLASS = "Server";

    public WhirledGameManager ()
    {
    }

    /**
     * Configures the oids of the winners of this game. If a game manager delegate wishes to handle
     * winner assignment, it should call this method and then call {@link #enddGame}.
     */
    public void setWinners (int[] winnerOids)
    {
        _winnerOids = winnerOids;
    }

    @Override
    public void occupantInRoom (BodyObject caller)
    {
        setAsInitialized(caller);

        super.occupantInRoom(caller);
    }

    @Override
    public void playerReady (BodyObject caller)
    {
        // if we're rematching...
        if (!_gameObj.isInPlay() && (_gameObj.roundId != 0) && _gameObj.players.length > 1) {
            // report to the other players that this player requested a rematch
            int pidx = _gameObj.getPlayerIndex(caller.getVisibleName());
            if (pidx != -1 && _playerOids[pidx] == 0) {
                systemMessage(WHIRLEDGAME_MESSAGE_BUNDLE,
                    MessageBundle.tcompose("m.rematch_requested", caller.getVisibleName()));
            }
        }

        super.playerReady(caller);
    }

    /**
     * Confirms that the caller can end the game (or restart it). Requires that they are a player
     * and that the game is not in play.
     */
    public void validateCanEndGame (ClientObject caller)
        throws InvocationException
    {
        if (!_gameObj.isInPlay()) {
            throw new InvocationException("e.already_ended");
        }
        validateUser(caller);
    }

    // from TurnGameManager
    public void turnWillStart ()
    {
    }

    // from TurnGameManager
    public void turnDidStart ()
    {
    }

    // from TurnGameManager
    public void turnDidEnd ()
    {
    }

    // from WhirledGameProvider
    public void endTurn (ClientObject caller, int nextPlayerId,
                         InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

//        // make sure this player is the turn holder
//        Name holder = _gameObj.turnHolder;
//        if (holder != null && !holder.equals(((BodyObject) caller).getVisibleName())) {
//            throw new InvocationException(InvocationCodes.ACCESS_DENIED);
//        }

//        Name nextTurnHolder = null;
//        if (nextPlayerId != 0) {
//            BodyObject target = getPlayerByOid(nextPlayerId);
//            if (target != null) {
//                nextTurnHolder = target.getVisibleName();
//            }
//        }

        _turnDelegate.endTurn(nextPlayerId);
    }

    // from WhirledGameProvider
    public void endRound (ClientObject caller, int nextRoundDelay,
                          InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        // let the game know that it is doing something stupid
        if (_gameObj.roundId < 0) {
            throw new InvocationException("m.round_already_ended");
        }

        // while we are between rounds, our round id is the negation of the round that just ended
        _gameObj.setRoundId(-_gameObj.roundId);

        // queue up the start of the next round if requested
        if (nextRoundDelay > 0) {
            new Interval(CrowdServer.omgr) {
                public void expired () {
                    if (_gameObj.isInPlay()) {
                        _gameObj.setRoundId(-_gameObj.roundId + 1);
                    }
                }
            }.schedule(nextRoundDelay * 1000L);
        }
    }

    // from WhirledGameProvider
    public void endGame (ClientObject caller, int[] winnerOids,
                         InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateCanEndGame(caller);
        setWinners(winnerOids);
        endGame();
    }

    // from WhirledGameProvider
    public void restartGameIn (ClientObject caller, int seconds,
                               InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        // queue up the start of the next game
        if (seconds > 0) {
            new Interval(CrowdServer.omgr) {
                public void expired () {
                    if (_gameObj.isActive() && !_gameObj.isInPlay()) {
                        startGame();
                    }
                }
            }.schedule(seconds * 1000L);

        } else {
            // start immediately
            if (_gameObj.isActive() && !_gameObj.isInPlay()) {
                startGame();
            }
        }
    }

    // from WhirledGameProvider
    public void sendMessage (ClientObject caller, String msg, Object data, int playerId,
                             InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        if (playerId == 0) {
            _gameObj.postMessage(WhirledGameObject.USER_MESSAGE, msg, data);
        } else {
            sendPrivateMessage(playerId, msg, data);
        }
    }

    // from WhirledGameProvider
    public void setProperty (ClientObject caller, String propName, Object data, Integer key,
        boolean isArray, boolean testAndSet, Object testValue,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);
        if (testAndSet && !_gameObj.testProperty(propName, testValue)) {
            return; // the test failed: do not set the property
        }
        setProperty(propName, data, key, isArray);
    }

    // from WhirledGameProvider
    public void getDictionaryLetterSet (
        ClientObject caller, String locale, String dictionary, int count, 
        InvocationService.ResultListener listener)
        throws InvocationException
    {
        getDictionaryManager().getLetterSet(locale, dictionary, count, listener);
    }
    
    // from WhirledGameProvider
    public void checkDictionaryWord (
        ClientObject caller, String locale, String dictionary, String word, 
        InvocationService.ResultListener listener)
        throws InvocationException
    {
        getDictionaryManager().checkWord(locale, dictionary, word, listener);
    }

    // from WhirledGameProvider
    public void addToCollection (ClientObject caller, String collName, byte[][] data,
                                 boolean clearExisting,
                                 InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);
        if (_collections == null) {
            _collections = new HashMap<String, ArrayList<byte[]>>();
        }

        // figure out if we're adding to an existing collection or creating a new one
        ArrayList<byte[]> list = null;
        if (!clearExisting) {
            list = _collections.get(collName);
        }
        if (list == null) {
            list = new ArrayList<byte[]>();
            _collections.put(collName, list);
        }

        CollectionUtil.addAll(list, data);
    }

    // from WhirledGameProvider
    public void getFromCollection (ClientObject caller, String collName, boolean consume, int count,
                                   String msgOrPropName, int playerId,
                                   InvocationService.ConfirmListener listener)
        throws InvocationException
    {
        validateUser(caller);

        int srcSize = 0;
        if (_collections != null) {
            ArrayList<byte[]> src = _collections.get(collName);
            srcSize = (src == null) ? 0 : src.size();
            if (srcSize >= count) {
                byte[][] result = new byte[count][];
                for (int ii=0; ii < count; ii++) {
                    int pick = RandomUtil.getInt(srcSize);
                    if (consume) {
                        result[ii] = src.remove(pick);
                        srcSize--;

                    } else {
                        result[ii] = src.get(pick);
                    }
                }

                if (playerId == 0) {
                    setProperty(msgOrPropName, result, null, false);
                } else {
                    sendPrivateMessage(playerId, msgOrPropName, result);
                }
                listener.requestProcessed(); // SUCCESS!
                return;
            }
        }
        
        // TODO: decide what we want to return here
        throw new InvocationException(String.valueOf(srcSize));
    }
    
    // from WhirledGameProvider
    public void mergeCollection (ClientObject caller, String srcColl, String intoColl,
                                 InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        // non-existent collections are treated as empty, so if the source doesn't exist, we
        // silently accept it
        if (_collections != null) {
            ArrayList<byte[]> src = _collections.remove(srcColl);
            if (src != null) {
                ArrayList<byte[]> dest = _collections.get(intoColl);
                if (dest == null) {
                    _collections.put(intoColl, src);
                } else {
                    dest.addAll(src);
                }
            }
        }
    }

    // from WhirledGameProvider
    public void setTicker (ClientObject caller, String tickerName, int msOfDelay,
                           InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        Ticker t;
        if (msOfDelay >= MIN_TICKER_DELAY) {
            if (_tickers != null) {
                t = _tickers.get(tickerName);
            } else {
                _tickers = new HashMap<String, Ticker>();
                t = null;
            }

            if (t == null) {
                if (_tickers.size() >= MAX_TICKERS) {
                    throw new InvocationException(ACCESS_DENIED);
                }
                t = new Ticker(tickerName, _gameObj);
                _tickers.put(tickerName, t);
            }
            t.start(msOfDelay);

        } else if (msOfDelay <= 0) {
            if (_tickers != null) {
                t = _tickers.remove(tickerName);
                if (t != null) {
                    t.stop();
                }
            }

        } else {
            throw new InvocationException(ACCESS_DENIED);
        }
    }

    // from WhirledGameProvider
    public void getCookie (ClientObject caller, final int playerOid,
                           InvocationService.InvocationListener listener)
        throws InvocationException
    {
        if (_gameObj.userCookies != null && _gameObj.userCookies.containsKey(playerOid)) {
            // already loaded: we do nothing
            return;
        }

        // we only start looking up the cookie if nobody else already is
        if (_cookieLookups.contains(playerOid)) {
            return;
        }

        BodyObject body = getOccupantByOid(playerOid);
        if (body == null) {
            log.debug("getCookie() called with invalid occupant [occupantId=" + playerOid + "].");
            throw new InvocationException(INTERNAL_ERROR);
        }

        // indicate that we're looking up a cookie
        _cookieLookups.add(playerOid);

        int ppId = getPlayerPersistentId(body);
        getCookieManager().getCookie(_gameconfig.getGameId(), ppId, new ResultListener<byte[]>() {
            public void requestCompleted (byte[] result) {
                // note that we're done with this lookup
                _cookieLookups.remove(playerOid);
                // result may be null: that's ok, it means we've looked up the user's nonexistent
                // cookie; also only set the cookie if the player is still in the room
                if (_gameObj.occupants.contains(playerOid) && _gameObj.isActive()) {
                    _gameObj.addToUserCookies(new UserCookie(playerOid, result));
                }
            }

            public void requestFailed (Exception cause) {
                log.warning("Unable to retrieve cookie [cause=" + cause + "].");
                requestCompleted(null);
            }
        });
    }

    // from WhirledGameProvider
    public void setCookie (ClientObject caller, byte[] value,
                           InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        // persist this new cookie
        getCookieManager().setCookie(
            _gameconfig.getGameId(), getPlayerPersistentId((BodyObject)caller), value);

        // and update the distributed object
        UserCookie cookie = new UserCookie(caller.getOid(), value);
        if (_gameObj.userCookies.containsKey(cookie.getKey())) {
            _gameObj.updateUserCookies(cookie);
        } else {
            _gameObj.addToUserCookies(cookie);
        }
    }

    /**
     * Called privately by the ThaneGameController when an agent's code is all set to go
     * and the game can startup.
     */
    public void agentReady (ClientObject caller)
    {
        log.info("Agent ready for " + caller);
        _gameAgentReady = true;
        
        if (allPlayersReady()) {
            playersAllHere();
        }
    }
    
    /**
     * Called privately by the ThaneGameController when anything in the agent's code domain
     * causes a line of debug or error tracing.
     */
    public void agentTrace (ClientObject caller, String trace)
    {
        // do nothing, subclasses may implement something interesting here
    }

    @Override // from GameManager
    public boolean allPlayersReady ()
    {
        if (!super.allPlayersReady()) {
            return false;
        }

        if (requiresAgent()) {
            return _gameAgent != null && _gameAgentReady;
        }

        return true;
    }

    /**
     * Test whether the privded client is the agent for this game.
     */
    public boolean isAgent (ClientObject caller)
    {
        return _gameAgent != null && _gameAgent.clientOid == caller.getOid();
    }

    /**
     * Returns the dictionary manager if it has been properly initialized. Throws an INTERNAL_ERROR
     * exception if it has not.
     */
    protected DictionaryManager getDictionaryManager ()
        throws InvocationException
    {
        DictionaryManager dictionary = DictionaryManager.getInstance();
        if (dictionary == null) {
            log.warning("DictionaryManager not initialized.");
            throw new InvocationException(INTERNAL_ERROR);
        }
        return dictionary;
    }

    /**
     * Helper method to send a private message to the specified player oid (must already be
     * verified).
     */
    protected void sendPrivateMessage (int playerOid, String msg, Object data)
        throws InvocationException
    {
        ClientObject target = null;

        if (playerOid == -1 && _gameAgent != null) {
            target = (ClientObject)CrowdServer.omgr.getObject(_gameAgent.clientOid);
        }
        else {
            target = getPlayerByOid(playerOid);
        }

        if (target == null) {
            // TODO: this code has no corresponding translation
            throw new InvocationException("m.player_not_around");
        }

        target.postMessage(WhirledGameObject.USER_MESSAGE + ":" + _gameObj.getOid(),
                           new Object[] { msg, data });
    }

    /**
     * Helper method to post a property set event.
     */
    protected void setProperty (String propName, Object value, Integer key, boolean isArray)
    {
        // apply the property set immediately
        try {
            Object oldValue = _gameObj.applyPropertySet(propName, value, key, isArray);
            _gameObj.postEvent(
                new PropertySetEvent(_gameObj.getOid(), propName, value, key, isArray, oldValue));
        } catch (WhirledGameObject.ArrayRangeException are) {
            log.info("Game attempted deprecated set semantics: setting cells of an empty array.");
        }
    }

    /**
     * Validate that the specified user has access to do things in the game.
     */
    protected void validateUser (ClientObject caller)
        throws InvocationException
    {
        // the server is always cool
        if (caller == null) {
            return;
        }

        // party games allow anyone to do things
        if (getMatchType() == GameConfig.PARTY) {
            return;
        }

        // regular players can do things only if seated
        if (caller instanceof BodyObject) {
            BodyObject body = (BodyObject)caller;
            if (getPlayerIndex(body.getVisibleName()) == -1) {
                throw new InvocationException(InvocationCodes.ACCESS_DENIED);
            }
            return;
        }

        // otherwise... this must be the agent
        if (!isAgent(caller)) {
            throw new InvocationException(InvocationCodes.ACCESS_DENIED);
        }
    }

    /**
     * Get the specified player body by Oid.
     */
    protected BodyObject getPlayerByOid (int oid)
    {
        // verify that they're a player
        switch (getMatchType()) {
        case GameConfig.PARTY:
            // all occupants are players in a party game
            break;

        default:
            if (!IntListUtil.contains(_playerOids, oid)) {
                return null; // not a player!
            }
            break;
        }

        return getOccupantByOid(oid);
    }

    /**
     * Get the specified occupant body by Oid.
     */
    protected BodyObject getOccupantByOid (int oid)
    {
        if (!_gameObj.occupants.contains(oid)) {
            return null;
        }
        // return the body
        return (BodyObject) CrowdServer.omgr.getObject(oid);
    }

    /**
     * Flag this user as now being initailized. Done once the usercode has connected.
     */
    protected void setAsInitialized (BodyObject body)
    {
        WhirledGameOccupantInfo info = (WhirledGameOccupantInfo) getOccupantInfo(body.getOid());
        if (info == null) {
            log.warning("Asked to set as initialized a non-occupant? [game=" + where() +
                        ", who=" + body.who() + "].");
        } else if (!info.initialized) {
            info.initialized = true;
            updateOccupantInfo(info);
        }
    }

    @Override
    protected PlaceObject createPlaceObject ()
    {
        return new WhirledGameObject();
    }

    @Override
    protected void didInit ()
    {
        super.didInit();

        // initialize the appropriate turn delegate
        if (getMatchType() == GameConfig.PARTY) {
            WhirledPartyTurnDelegate del = new WhirledPartyTurnDelegate();
            _turnDelegate = del;
            addDelegate(del);
            del.didInit(_config);

        } else {
            WhirledSeatedTurnDelegate del = new WhirledSeatedTurnDelegate();
            _turnDelegate = del;
            addDelegate(del);
            del.didInit(_config);
        }
    }

    @Override
    protected void didStartup ()
    {
        super.didStartup();

        _gameObj = (WhirledGameObject) _plobj;
        _gameObj.setWhirledGameService((WhirledGameMarshaller)
            CrowdServer.invmgr.registerDispatcher(new WhirledGameDispatcher(this)));

        // register an agent for this game if required
        _gameAgent = createAgent();
        if (_gameAgent != null) {
            getBureauRegistry().startAgent(_gameAgent);
        }
    }

    /**
     * Check if this game requires an agent.
     */
    protected boolean requiresAgent ()
    {
        WhirledGameConfig cfg = (WhirledGameConfig)_gameconfig;
        String code = cfg.getGameDefinition().getServerMediaPath(cfg.getGameId());
        return !StringUtil.isBlank(code);
    }

    /**
     * Creates the agent for this game. An agent is optional server-side code for a 
     * game and is managed by the {@link BureauRegistry}.
     * @return the new agent object or null if the game does not require it
     */
    protected GameAgentObject createAgent ()
    {
        WhirledGameConfig cfg = (WhirledGameConfig)_gameconfig;
        GameDefinition def = cfg.getGameDefinition();
        int id = cfg.getGameId();
        String code = def.getServerMediaPath(id);

        if (StringUtil.isBlank(code)) {
            return null;
        }

        GameAgentObject gameAgentObj = new GameAgentObject();
        gameAgentObj.gameOid = _gameObj.getOid();
        gameAgentObj.config = new ThaneGameConfig(id, def);
        gameAgentObj.bureauId = "whirled-game-" + def.getBureauId(id);
        // We assume this is a thane/tamarin abc pacakage. TODO: do we need to check that?
        gameAgentObj.bureauType = THANE_BUREAU;
        gameAgentObj.code = code;
        if (StringUtil.isBlank(def.server)) {
            gameAgentObj.className = DEFAULT_SERVER_CLASS;
        } else {
            gameAgentObj.className = def.server;
        }
        return gameAgentObj;
    }

    @Override // from PlaceManager
    protected void bodyEntered (int bodyOid)
    {
        super.bodyEntered(bodyOid);

        // if we have no controller, then our new friend gets control
        if (_gameObj.controllerOid == 0) {
            _gameObj.setControllerOid(bodyOid);
        }
    }

    @Override // from PlaceManager
    protected void bodyUpdated (OccupantInfo info)
    {
        super.bodyUpdated(info);

        // if the controller just disconnected, reassign control
        if (info.status == OccupantInfo.DISCONNECTED && info.bodyOid == _gameObj.controllerOid) {
            _gameObj.setControllerOid(getControllerOid());

        // if everyone in the room was disconnected and this client just reconnected, it becomes
        // the new controller
        } else if (_gameObj.controllerOid == 0) {
            _gameObj.setControllerOid(info.bodyOid);
        }
    }

    @Override // from PlaceManager
    protected void bodyLeft (int bodyOid)
    {
        super.bodyLeft(bodyOid);

        // if this player was the controller, reassign control
        if (bodyOid == _gameObj.controllerOid) {
            _gameObj.setControllerOid(getControllerOid());
        }

        // nix any of this player's cookies
        if (_gameObj.userCookies != null && _gameObj.userCookies.containsKey(bodyOid)) {
            _gameObj.removeFromUserCookies(bodyOid);
        }
    }

    @Override // from GameManager
    protected void playersAllHere ()
    {
        switch (getMatchType()) {
        default:
        case GameConfig.SEATED_GAME:
            super.playersAllHere();
            break;

        case GameConfig.PARTY:
        case GameConfig.SEATED_CONTINUOUS:
            // the first time the first player calls playerReady() in a party or seated continuous
            // game, we start the game; after that it's up to the game to restart itself
            if (!_haveAutoStarted && _gameobj.state == WhirledGameObject.PRE_GAME) {
                _haveAutoStarted = true;
                startGame();
            }
            break;
        }
    }

    @Override
    protected void didShutdown ()
    {
        CrowdServer.invmgr.clearDispatcher(_gameObj.whirledGameService);
        stopTickers();

        if (_gameAgent != null) {
            getBureauRegistry().destroyAgent(_gameAgent);
            _gameAgent = null;
        }

        super.didShutdown();
    }

    @Override 
    protected void gameWillStart ()
    {
        // clear out the turn holder in case we're restarting
        _gameObj.setTurnHolder(null);

        super.gameWillStart();
    }

    @Override 
    protected void gameDidStart ()
    {
        super.gameDidStart();

        // set our round id to 1 which will trigger the start of the first round
        _gameObj.setRoundId(1);
    }

    @Override
    protected void gameDidEnd ()
    {
        stopTickers();

        super.gameDidEnd();

        // Whirled games immediately reset to PRE_GAME after they end so that they can be
        // restarted if desired by having all players call playerReady() again
        _gameObj.setState(WhirledGameObject.PRE_GAME);
    }

    @Override
    protected void assignWinners (boolean[] winners)
    {
        if (_winnerOids != null) {
            for (int oid : _winnerOids) {
                int index = IntListUtil.indexOf(_playerOids, oid);
                if (index >= 0 && index < winners.length) {
                    winners[index] = true;
                }
            }
            _winnerOids = null;
        }
    }

    /**
     * Stop and clear all tickers.
     */
    protected void stopTickers ()
    {
        if (_tickers != null) {
            for (Ticker ticker : _tickers.values()) {
                ticker.stop();
            }
            _tickers = null;
        }
    }

    /**
     * Returns the oid of a player to whom to assign control of the game or zero if no players
     * qualify for control.
     */
    protected int getControllerOid ()
    {
        for (OccupantInfo info : _gameObj.occupantInfo) {
            if (info.status != OccupantInfo.DISCONNECTED) {
                return info.bodyOid;
            }
        }
        return 0;
    }

    /**
     * Get the cookie manager, and do a bit of other setup.
     */
    protected GameCookieManager getCookieManager ()
    {
        if (_cookMgr == null) {
            _cookMgr = createCookieManager();
            _gameObj.setUserCookies(new DSet<UserCookie>());
        }
        return _cookMgr;
    }

    /**
     * Creates the cookie manager we'll use to store user cookies.
     */
    protected GameCookieManager createCookieManager ()
    {
        return new GameCookieManager();
    }

    /**
     * Access the bureaus for this game manager, normally returns the server's global instance.
     */
    abstract protected BureauRegistry getBureauRegistry ();

    /**
     * A timer that fires message events to a game.
     */
    protected static class Ticker
    {
        /**
         * Create a Ticker.
         */
        public Ticker (String name, WhirledGameObject gameObj)
        {
            _name = name;
            // once we are constructed, we want to avoid calling methods on dobjs.
            _oid = gameObj.getOid();
            _omgr = gameObj.getManager();
        }

        public void start (int msOfDelay)
        {
            _value = 0;
            _interval.schedule(0, msOfDelay);
        }

        public void stop ()
        {
            _interval.cancel();
        }

        /**
         * The interval that does our work. Note well that this is not a 'safe' interval that
         * operates using a RunQueue.  This interval instead does something that we happen to know
         * is safe for any thread: posting an event to the dobj manager.  If we were using a
         * RunQueue it would be the same event queue and we would be posted there, wait our turn,
         * and then do the same thing: post this event. We just expedite the process.
         */
        protected Interval _interval = new Interval() {
            public void expired () {
                _omgr.postEvent(new MessageEvent(
                    _oid, WhirledGameObject.TICKER, new Object[] { _name, _value++ }));
            }
        };

        protected int _oid;
        protected DObjectManager _omgr;
        protected String _name;
        protected int _value;
    } // End: static class Ticker

    /** A nice casted reference to the game object. */
    protected WhirledGameObject _gameObj;

    /** Our turn delegate. */
    protected WhirledGameTurnDelegate _turnDelegate;

    /** The map of collections, lazy-initialized. */
    protected HashMap<String, ArrayList<byte[]>> _collections;

    /** The map of tickers, lazy-initialized. */
    protected HashMap<String, Ticker> _tickers;

    /** Tracks which cookies are currently being retrieved from the db. */
    protected ArrayIntSet _cookieLookups = new ArrayIntSet();

    /** The array of winner oids, after the user has filled it in. */
    protected int[] _winnerOids;

    /** Handles the storage of our user cookies; lazily initialized. */
    protected GameCookieManager _cookMgr;

    /** Tracks whether or not we've auto-started a non-seated game. Unfortunately there's no way to
     * derive this from existing game state. */
    protected boolean _haveAutoStarted;

    /** The agent for this game or null if the game has no agent. */
    protected GameAgentObject _gameAgent;

    /** Set by <code>agentReady</code>. */
    protected boolean _gameAgentReady;

    /** The minimum delay a ticker can have. */
    protected static final int MIN_TICKER_DELAY = 50;

    /** The maximum number of tickers allowed at one time. */
    protected static final int MAX_TICKERS = 3;
}
