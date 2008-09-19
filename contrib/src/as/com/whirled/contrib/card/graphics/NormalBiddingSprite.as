// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.card.graphics {

import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.display.SimpleButton;
import com.threerings.util.MultiLoader;
import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.card.Debug;
import com.whirled.contrib.card.trick.Bids;
import com.whirled.contrib.card.trick.BidEvent;

/** Represents the interface for normal bidding (nil to 13). It uses an embedded movie with 
 *  predefined button objects within it. Buttons are simply hidden when they are not clickable. */
public class NormalBiddingSprite extends Sprite
{
    /** Create a new interface.
     *  @param bids allows the sprite to update automatically when it is time to bid (or not)
     *  @param movie the embedded movie object containing all the buttons for bidding
     *  @param buttonZeroName the name of the zeroth button; other button names are computed
     *  from this name by replacing the "0" with the desired number 
     *  @param labelColor the outline color of the "Select your bid" text 
     *  @param labelBottom the vertical offset of the bottom of the label text above the movie
     *  @param fudgeOffset the slight horizontal offset necessary to center the movie (we think this
     *  may be necessary due to shadows, but it looks better with it */
    public function NormalBiddingSprite (
        bids :Bids, 
        movie :Class,
        buttonZeroName :String,
        labelColor :uint,
        labelBottom :int,
        fudgeOffset :int)
    {
        _bids = bids;

        MultiLoader.getContents(movie, gotContent);

        _buttonNamePrefix = buttonZeroName.slice(
            0, buttonZeroName.indexOf("0"));

        var label :Text = new Text(Text.HUGE_HARD_ITALIC, 0xFFFFFF, labelColor);
        label.text = "Select your bid:";
        label.bottomY = labelBottom;
        addChild(label);

        _bids.addEventListener(BidEvent.REQUESTED, bidListener);
        _bids.addEventListener(BidEvent.SELECTED, bidListener);

        visible = false;

        function gotContent (movie :DisplayObjectContainer) :void {
            _movie = movie;

            Debug.debug("Normal movie is " + _movie.width + " x " + _movie.height);

            _movie.x = -_movie.width / 2 + fudgeOffset;
            _movie.y = -_movie.height / 2;

            addChild(_movie);

            setupButtons();
        }
    }

    protected function bidListener (event :BidEvent) :void
    {
        if (event.type == BidEvent.REQUESTED) {
            // values < 0 are reserved for special bid requests
            if (event.value >= 0) {
                visible = true;
                setMaxBid(event.value);
            }
        }
        else if (event.type == BidEvent.SELECTED) {
            // values < 0 are reserved for special bid requests
            if (event.value >= 0) {
                visible = false;
            }
        }
    }

    protected function setMaxBid (max :int) :void
    {
        _maxBid = max;
        if (_movie != null) {
            for (var i :int = 1; i < NUM_BUTTONS; ++i) {
                getButton(i).visible = (i <= _maxBid);
            }
        }
    }

    /** Add all the button listeners and take into account the maximum bid. */
    protected function setupButtons () :void
    {
        for (var i :int = 0; i < NUM_BUTTONS; ++i) {
            getButton(i).addEventListener(MouseEvent.CLICK, clickListener);
        }

        // redo previous call to setMaxBid if any
        setMaxBid(_maxBid);
    }

    /** Get the button for a given bid amount. */
    protected function getButton (num :int) :SimpleButton
    {
        return SimpleButton(DisplayUtil.findInHierarchy(
            _movie.getChildAt(0), buttonName(num)));
    }

    /** Dispatch a click on a bid to the game model. */
    protected function clickListener (event :MouseEvent) :void
    {
        var butt :SimpleButton = SimpleButton(event.target);
        Debug.debug("Button pressed: " + butt.name);
        var num :int = buttonNumber(butt.name);
        if (num <= _maxBid) {
            _bids.select(num);
            visible = false;
        }
    }

    /** Retrieve the name of a button for a given bid value. */
    protected function buttonName (number :int) :String
    {
        return _buttonNamePrefix + number;
    }

    /** Retrieve the number of a button of a given name. */
    protected function buttonNumber (name :String) :int
    {
        return parseInt(name.slice(_buttonNamePrefix.length));
    }

    protected var _bids :Bids;
    protected var _movie :DisplayObjectContainer;
    protected var _maxBid :int;
    protected var _buttonNamePrefix :String;

    protected static const NUM_BUTTONS :int = 14;
}

}
