//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.SetListener;

import com.whirled.game.data.GameContentOwnership;
import com.whirled.game.data.GameData;
import com.whirled.game.data.WhirledPlayerObject;

/**
 * Listens for game content related events on a player object and reports appropriate events to the
 * backend.
 */
public class ContentListener implements SetListener
{
    public function ContentListener (playerId :int, gameId :int, target :BaseGameBackend)
    {
        _playerId = playerId;
        _gameId = gameId;
        _target = target;
    }

    // from interface SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (event.getName() != WhirledPlayerObject.GAME_CONTENT) {
            return;
        }

        var content :GameContentOwnership = (event.getEntry() as GameContentOwnership);
        if (content.gameId == _gameId &&
            // we only want to notify on the addition of item and level pack data
            (content.type == GameData.LEVEL_DATA || content.type == GameData.ITEM_DATA)) {
            _target.notifyGameContentAdded(content.type, content.ident, _playerId);
        }
    }

    // from interface SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        if (event.getName() != WhirledPlayerObject.GAME_CONTENT) {
            return;
        }
        var content :GameContentOwnership = (event.getEntry() as GameContentOwnership);
        var ocontent :GameContentOwnership = (event.getOldEntry() as GameContentOwnership);
        if (content.gameId == _gameId && content.type == GameData.ITEM_DATA &&
            content.count < ocontent.count) {
            _target.notifyGameContentConsumed(content.type, content.ident, _playerId);
        }
    }

    // from interface SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (event.getName() != WhirledPlayerObject.GAME_CONTENT) {
            return;
        }
        var content :GameContentOwnership = (event.getOldEntry() as GameContentOwnership);
        if (content.gameId == _gameId && content.type == GameData.ITEM_DATA) {
            _target.notifyGameContentConsumed(content.type, content.ident, _playerId);
        }
    }

    protected var _playerId :int;
    protected var _gameId :int;
    protected var _target :BaseGameBackend;
}
}
