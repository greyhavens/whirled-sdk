//
// $Id$

package com.whirled.client {

import flash.errors.IllegalOperationError;

import mx.core.ClassFactory;
import mx.core.ScrollPolicy;

import mx.collections.ArrayCollection;
import mx.collections.Sort;

import mx.containers.VBox;

import mx.controls.Label;
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
public class PlayerList extends VBox
    implements AttributeChangeListener, ElementUpdateListener, SetListener
{
    public function PlayerList ()
    {
        super();

        // set up the UI
        width = 280;
        height = 125;
        //percentHeight = 25; // doesn't work
        _list = new List();
        _list.verticalScrollPolicy = ScrollPolicy.ON;
        _list.selectable = false; // don't let the user select, as we use selection to show turn
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

    /**
     * Start up this player list.
     */
    public function startup (plobj :PlaceObject) :void
    {
        _gameObj = plobj as GameObject;
        _gameObj.addListener(this);

        var record :PlayerRecord;

        // find all the current occupants and add them to the set
        for each (var occInfo :OccupantInfo in _gameObj.occupantInfo.toArray()) {
            record = new PlayerRecord();
            record.setup(occInfo);

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
            }

            record.isPlayer = true;

            if (newRecord) {
                _byName.put(name, record);
                _players.addItem(record);
            }
        }

        _players.refresh();

        // set the current turn-holder, if applicable
        if (_gameObj is TurnGameObject) {
            record = _byName.get((_gameObj as TurnGameObject).getTurnHolder());
            _list.selectedItem = record;
        }
    }

    /**
     * Shut down this player list.
     */
    public function shutdown () :void
    {
        _gameObj.removeListener(this);
        _gameObj = null;

        _byOid.clear();
        _byName.clear();
        _players.removeAll();
    }

    /**
     * Label the players list with a string.
     */
    public function setLabel (label :String) :void
    {
        if (label == null) {
            if (_label != null) {
                removeChild(_label);
                _label = null;
            }

        } else {
            if (_label == null) {
                _label = new Label();
                _label.setStyle("textAlign", "center");
                _label.percentWidth = 100;
                addChildAt(_label, 0);
            }
            _label.text = label;
        }
    }

    /**
     * Clear out the score data for all records.
     */
    public function clearScores (clearValue :Object = null, sortValuesToo :Boolean = false) :void
    {
        for (var ii :int = _players.length - 1; ii >= 0; ii--) {
            var record :PlayerRecord = _players.getItemAt(ii) as PlayerRecord;
            record.scoreData = clearValue;
            if (sortValuesToo) {
                record.sortData = null;
            }
        }
        _players.refresh();
    }

    /**
     * Set the scores for players from an array. You may specify either the scores or
     * the sortValues or both.
     */
    public function setPlayerScores (scores :Array, sortValues :Array = null) :void
    {
        var names :Array = _gameObj.players;

        if (scores != null && scores.length != names.length) {
            throw new IllegalOperationError("The length of the scores array does not match " +
                "the length of the players array.");
        }
        if (sortValues != null && sortValues.length != names.length) {
            throw new IllegalOperationError("The length of the sortValues array does not match " +
                "the length of the players array.");
        }

        for (var ii :int = 0; ii < names.length; ii++) {
            var record :PlayerRecord = _byName.get(names[ii]) as PlayerRecord;
            if (scores != null) {
                record.scoreData = scores[ii];
            }
            if (sortValues != null) {
                record.sortData = sortValues[ii];
            }
        }
        _players.refresh();
    }

    /**
     * Set the scores for any occupants. The keys are the occupantId (oid), the value is
     * used for the score, or if an array, the first value is the score the 2nd is the sortData.
     */
    public function setMappedScores (scores :Object) :void
    {
        for (var playerId :String in scores) {
            var record :PlayerRecord = _byOid.get(int(playerId));
            if (record != null) {
                var data :Object = scores[playerId];
                if (data is Array) {
                    var arr :Array = data as Array;
                    record.scoreData = arr[0];
                    record.sortData = arr[1];
                } else {
                    record.scoreData = data;
                }
            }
        }
        _players.refresh();
    }

    // from AttributeChangeListener
    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        // update the displayed turn holder
        if ((_gameObj is TurnGameObject) &&
                (event.getName() == (_gameObj as TurnGameObject).getTurnHolderFieldName())) {
            var record :PlayerRecord = _byName.get(event.getValue()) as PlayerRecord;
            _list.selectedItem = record;
        }
    }

    // from ElementUpdateListener
    public function elementUpdated (event :ElementUpdatedEvent) :void
    {
        // TODO: changes to players array...?
    }

    // from SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            var occInfo :OccupantInfo = (event.getEntry() as OccupantInfo);
            // if the occupant is a player, they may already have a record
            var record :PlayerRecord = _byName.get(occInfo.username) as PlayerRecord;
            var newRecord :Boolean = (record == null);
            if (newRecord) {
                record = new PlayerRecord();
            }
            record.setup(occInfo);

            _byOid.put(occInfo.bodyOid, record);
            if (newRecord) {
                _byName.put(occInfo.username, record);
                _players.addItem(record);

            } else {
                _players.itemUpdated(record);
            }
        }
    }

    // from SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            // I guess we might be updating the name or the headshot
            var occInfo :OccupantInfo = (event.getEntry() as OccupantInfo);
            var record :Object = _byOid.get(occInfo.bodyOid);
            record.setup(occInfo);
            _players.itemUpdated(record);
        }
    }

    // from SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            var occInfo :OccupantInfo = (event.getOldEntry() as OccupantInfo);
            var record :PlayerRecord = _byOid.remove(occInfo.bodyOid) as PlayerRecord;

            // if this is a player, strip the oid but leave it in the lists
            if (ArrayUtil.contains(_gameObj.players, occInfo.username)) {
                record.setup(null);
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
     */
    protected function sortFunction (o1 :Object, o2 :Object, fields :Array = null) :int
    {
        return (o1 as PlayerRecord).compareTo(o2);
    }

    /** The game object. */
    protected var _gameObj :GameObject;

    /** An optional label for the list of players. */
    protected var _label :Label;

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

import mx.controls.Image;
import mx.controls.Label;

import mx.core.ScrollPolicy;

import com.threerings.util.Comparable;

import com.threerings.crowd.data.OccupantInfo;

import com.whirled.data.WhirledOccupantInfo;

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

    /** The headshot url. */
    public var headshotUrl :String;

    /** Is it an actual player in the game's players array? */
    public var isPlayer :Boolean;

    /** Optional score data to display. */
    public var scoreData :Object;

    /** Optional sort ordering for this record. */
    public var sortData :Object;

    /**
     * Called to configure this PlayerRecord.
     */
    public function setup (occInfo :OccupantInfo) :void
    {
        if (occInfo != null) {
            name = occInfo.username.toString();
            oid = occInfo.bodyOid;
            if (occInfo is WhirledOccupantInfo) {
                headshotUrl = (occInfo as WhirledOccupantInfo).getHeadshotURL();

            } else {
                headshotUrl = null;
            }

        } else {
            oid = 0;
            headshotUrl = null;
        }
    }

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
                // if equal, put actual players ahead of watchers
                cmp = compare(this.isPlayer, that.isPlayer);
//                trace("isPlayer: " + cmp);
                if (cmp == 0) {
                    // if equal, compare by name (lowest first)
                    cmp = compare(that.name, this.name);
//                    trace("name: " + cmp);
                    if (cmp == 0) {
                        // if equal, compare by oid
                        cmp = compare(this.oid, that.oid);
//                        trace("oid: " + cmp);
                    }
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


// TODO: fuck fuck fuck. It's probably the case that a renderer that gets scrolled off and
// back on will have to re-load the headshot completely.
class PlayerRenderer extends HBox
{
    public function PlayerRenderer ()
    {
        super();

        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;
        // the horizontalGap should be 8...
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

        // 280 total width (??) - scrollbar thickness (16) - two gaps (8 each) = 228
        // 20 for headshot + 118 for name + 90 for score = 228
        addChild(_headshot = new Image());
        _headshot.height = 20; // 1/3 of headshot size
        _headshot.width = 20;
        _headshot.maintainAspectRatio = true;

        addChild(_nameLabel = new Label());
        _nameLabel.width = 118;

        addChild(_scoreLabel = new Label());
        _scoreLabel.width = 90;

        configureUI();
    }

    /**
     * Update the UI elements with the data we're displaying.
     */
    protected function configureUI () :void
    {
        var record :PlayerRecord = this.data as PlayerRecord;
        if (record != null) {
            _headshot.source = record.headshotUrl;
            _nameLabel.text = record.name;
            _nameLabel.setStyle("color",
                (record.oid != 0) ? PRESENT_NAME_COLOR : ABSENT_NAME_COLOR);
            _scoreLabel.text = (record.scoreData == null) ? "" : String(record.scoreData);
            _scoreLabel.setStyle("textAlign", (record.scoreData is Number) ? "right" : "left");

        } else {
            _nameLabel.text = "";
            _headshot.source = null;
            _scoreLabel.text = "";
        }
    }

    /** Display's the user's icon. */
    protected var _headshot :Image;

    /** The label used to display the player's name. */
    protected var _nameLabel :Label;

    /** The label used to display score data, if applicable. */
    protected var _scoreLabel :Label;

    /** The color of the name label when a player or occupant is present in the room. */
    protected static const PRESENT_NAME_COLOR :uint = 0x000000;

    /** The color of the name label when a player is absent. */
    protected static const ABSENT_NAME_COLOR :uint =0x777777;
}
