//
// $Id$

package com.whirled.client {

import mx.core.ClassFactory;

import mx.collections.ArrayCollection;
import mx.collections.Sort;

import mx.containers.VBox;

import mx.controls.List;

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Name;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.ElementUpdateListener;
import com.threerings.presents.dobj.ElementUpdatedEvent;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.SetListener;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.parlor.game.data.GameObject;

import com.threerings.parlor.turn.data.TurnGameObject;

/**
 * A standard flex players list for use in games.
 */
// TODO
// set scores by id
// set scores by passing in an array corresponding to the players array
// clear scores function to clear all scores
public class PlayerList extends VBox
    implements AttributeChangeListener, ElementUpdateListener, SetListener
{
    public function PlayerList ()
    {
        super();

        // set up the UI
        width = 280;
        height = 250;
        //percentHeight = 50; // doesn't work
        _list = new List();
        _list.percentWidth = 100;
        _list.percentHeight = 100;
        _list.itemRenderer = new ClassFactory(PlayerRenderer);
        _list.dataProvider = _players;

        addChild(_list);

        // set up the sort for the collection
        var sort :Sort = new Sort();
        sort.compareFunction = sortFunction;
        _players.sort = sort;
    }

    public function startup (plobj :PlaceObject) :void
    {
        trace("==========PlayerList:startup");

        _gameObj = plobj as GameObject;
        _gameObj.addListener(this);

        var record :PlayerRecord;

        // find all the current occupants and add them to the set
        for each (var occInfo :OccupantInfo in _gameObj.occupantInfo.toArray()) {
            record = new PlayerRecord();
            record.name = occInfo.username.toString();
            record.oid = occInfo.bodyOid;

            _byName.put(occInfo.username, record);
            _byOid.put(occInfo.bodyOid, record);
            _players.addItem(record);
        }

        // add all the players specified in the players array, if any
        for each (var name :Name in _gameObj.players) {
            record = _byName.get(name) as PlayerRecord;
            var newRecord :Boolean = (record == null);
            if (newRecord) {
                record = new PlayerRecord();
                record.name = name.toString();

                _byName.put(name, record);
                _players.addItem(record);
            }
        }

        _players.refresh();
    }

    public function shutdown () :void
    {
        trace("==========PlayerList:shutdown");
        _gameObj.removeListener(this);
        _gameObj = null;

        _byOid.clear();
        _byName.clear();
        _players.removeAll();
    }

    // from AttributeChangeListener
    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        // TODO: turn changes
    }

    // from ElementUpdateListener
    public function elementUpdated (event :ElementUpdatedEvent) :void
    {
        // TODO: changes to players array
    }

    // from SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            var occInfo :OccupantInfo = (event.getEntry() as OccupantInfo);
            var record :PlayerRecord = _byName.get(occInfo.username) as PlayerRecord;
            var newRecord :Boolean = (record == null);
            if (newRecord) {
                record = new PlayerRecord();
                record.name = occInfo.username.toString();
                _byName.put(occInfo.username, record);
            }

            record.oid = occInfo.bodyOid;
            _byOid.put(occInfo.bodyOid, record);

            if (newRecord) {
                _players.addItem(record);

            } else {
                _players.itemUpdated(record);
            }
        }
    }

    // from SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
//        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
//            // I guess we might be updating the name..
//            var occInfo :OccupantInfo = (event.getEntry() as OccupantInfo);
//            var record :Object = _byOid.get(occInfo.bodyOid);
//            record.name = occInfo.username.toString();
//            _players.itemUpdated(record);
//        }
    }

    // from SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            var occInfo :OccupantInfo = (event.getOldEntry() as OccupantInfo);
            var record :PlayerRecord = _byOid.remove(occInfo.bodyOid) as PlayerRecord;

            // if this is a player, strip the oid but leave it in the lists
            if (ArrayUtil.contains(_gameObj.players, occInfo.username)) {
                record.oid = 0;
                _players.itemUpdated(record);

            } else {
                // otherwise, remove it completely
                _byName.remove(occInfo.username);
                _players.removeItemAt(_players.getItemIndex(record));
            }
        }
    }

    /**
     * The sort function that will be used to display occupant records.
     *
     * @return -1 if rec1 should be first, 0 if they are equal (?), 1 if rec2 should be first.
     */
    protected function sortFunction (o1 :Object, o2 :Object, fields :Array = null) :int
    {
        return (o1 as PlayerRecord).compareTo(o2);
    }

    /** The game object. */
    protected var _gameObj :GameObject;

//    /** The occupantId of the occupant that's instatiated this widget. */
//    protected var _ourId :int;

    /** The List widget that displays the players. */
    protected var _list :List;

    /** A mapping of oid -> record */
    protected var _byOid :HashMap = new HashMap();

    /** A mapping of name -> record. */
    protected var _byName :HashMap = new HashMap();

    /** A collection of the records, used as backing for the List. Note that _byOid, _byName,
     * and this collection all refer to the same record objects. */
    protected var _players :ArrayCollection = new ArrayCollection();
}
}

import mx.containers.HBox;

import mx.controls.Label;

import mx.core.ScrollPolicy;

import com.threerings.util.Comparable;

/**
 * A record for tracking player data.
 */
class PlayerRecord
    implements Comparable
{
    /** The player's name. */
    public var name :String;

    /** The player's oid, or 0 if the player is not present. */
    public var oid :int;

    /** Is it an actual player in the game's players array? */
    public var isPlayer :Boolean;

    /** Optional score data to display. */
    public var scoreData :Object;

    /** Optional sort ordering for this record. */
    public var sortData :Object;

    // from Comparable
    public function compareTo (other :Object) :int
    {
        var that :PlayerRecord = other as PlayerRecord;

//        trace("Comparing " + this.name + " and " + that.name);

        // compare by sortData
        var cmp :int = compare(this.sortData, that.sortData);
//        trace("SortData: " + cmp);
        if (cmp == 0) {
            // if equal, compare by scoreData
            cmp = compare(this.scoreData, that.scoreData);
//            trace("scoreData: " + cmp);
            if (cmp == 0) {
                // if equal, compare by name (lowest first)
                cmp = compare(that.name, this.name);
//                trace("name: " + cmp);
                if (cmp == 0) {
                    // if equal, compare by oid
                    cmp = compare(this.oid, that.oid);
//                    trace("oid: " + cmp);
                }
            }
        }
        return cmp;
    }

    /**
     * Comparison utility method that sorts non-null over null, and otherwise
     * uses actionscript's greater than or less than operators to magically compare
     * most values.
     */
    protected static function compare (o1 :Object, o2 :Object) :int
    {
        if (o1 != null) {
            if (o2 == null || o1 > o2) {
                return -1;

            } else if (o1 < o2) {
                return 1;

            } else {
                return 0;
            }

        } else if (o2 != null) {
            return 1;

        } else {
            return 0;
        }
    }
}

class PlayerRenderer extends HBox
{
    public function PlayerRenderer ()
    {
        super();

        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;
    }

    override public function set data (value :Object) :void
    {
        super.data = value;

        if (processedDescriptors) {
            configureUI();
        }
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        addChild(_nameLabel = new Label());
        _nameLabel.maxWidth = 100;

        configureUI();
    }

    /**
     * Update the UI elements with the data we're displaying.
     */
    protected function configureUI () :void
    {
        var record :PlayerRecord = this.data as PlayerRecord;
        if (record != null) {
            _nameLabel.text = record.name;
            _nameLabel.setStyle("color", (record.oid != 0) ? 0x000000 : 0x777777);

        } else {
            _nameLabel.text = "";
        }
    }

    /** The label used to display the player's name. */
    protected var _nameLabel :Label;
}
