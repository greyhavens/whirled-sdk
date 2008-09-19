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
import flash.events.MouseEvent;
import com.whirled.contrib.card.Card;
import com.whirled.contrib.card.Debug;
import com.threerings.util.MultiLoader;
import flash.display.MovieClip;

/**
 * Represents a card graphic with a few appearance flags. It relies on an embedded movie 
 * object where each frame in the movie is a card. The names of the frames must match the
 * short names provided by the Card class.
 */
public class CardSprite extends Sprite
{
    /** Normal appearance */
    public static const NORMAL :CardState = 
        new CardState(0xffffff, 0.0, "normal");

    /** Disabled appearance */
    public static const DISABLED :CardState = 
        new CardState(0x808080, 0.3, "disabled");

    /** Highlighted appearance */
    public static const HIGHLIGHTED :CardState = 
        new CardState(0xffffff, 0.0, "highlighted");

    /** Emphasized appearance */
    public static const EMPHASIZED :CardState = 
        new CardState(0xffffff, 0.0, "emphasized");

    /** For debugging, give each card sprite a unique id. */
    public static var nextSpriteId :int = 0;

    /** Create a new card sprite. */
    public function CardSprite (
        card :Card, 
        deck :Class,
        width :int,
        height :int)
    {
        _card = card;
        _cover = new Sprite();
        _state = NORMAL;
        _id = nextSpriteId++;
        _width = width;
        _height = height;

        Debug.debug("Requesting movie for " + _card + ", id " + _id);
        MultiLoader.getContents(deck, gotDeck);
    }

    /** Access the underlying card object. */
    public function get card () :Card
    {
        return _card;
    }

    /** Access to the card's highlight state. */
    public function get state () :CardState
    {
        return _state;
    }

    /** Access to the card's highlight state. */
    public function set state (state :CardState) :void
    {
        if (_state != state) {
            _state = state;
            update();
        }
    }

    /** @inheritDoc */
    // From Object
    override public function toString () :String
    {
        var stateStr :String = _state.toString();
        var superStr :String = super.toString();
        var parentStr :String = parent == null ? "null" : parent.toString();
        var cardStr :String = _card == null ? "back" : _card.toString();
        return "CardSprite " + cardStr + " (" + stateStr + ") " + 
            superStr + " in " + parentStr;
    }
    
    protected function gotDeck (clip :MovieClip) :void
    {
        Debug.debug("Got movie for " + _card + ", id " + _id + ", parent is " + parent);

        _deck = clip;
        if (card.faceDown) {
            _deck.gotoAndStop(BACK_FRAME);
        }
        else {
            _deck.gotoAndStop(card.string);
        }
        _deck.x = -_width / 2;
        _deck.y = -_height / 2;
        _deck.scaleX = _width / _deck.width;
        _deck.scaleY = _height / _deck.height;
        addChild(_deck);
        _deck.addChild(_cover);
    }

    protected function update () :void
    {
        _cover.alpha = _state.alpha;
        _cover.graphics.clear();
        _cover.graphics.beginFill(_state.color);
        _cover.graphics.drawRect(0, 0, _width, _height);
        _cover.graphics.endFill();
    }

    protected var _card :Card;
    protected var _state :CardState;
    protected var _deck :MovieClip;
    protected var _cover :Sprite;
    protected var _id :int;
    protected var _width :int;
    protected var _height :int;

    protected static const BACK_FRAME :String = "CB";
}

}

