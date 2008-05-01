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
import flash.display.Bitmap;
import com.threerings.flash.Vector2;
import com.threerings.util.MultiLoader;
import com.whirled.contrib.card.trick.Bids;
import com.whirled.contrib.card.trick.BidEvent;
import com.whirled.contrib.card.Table;
import com.whirled.contrib.card.trick.Scores;
import com.whirled.contrib.card.trick.ScoresEvent;
import com.whirled.contrib.card.Team;

/** Represents a team display. Includes a placeholder box and last trick display. */
public class TeamSprite extends Sprite
{
    /** Create a new team sprite. Long names will be truncated with an ellipsis.
     *  @param scores the scores object for the game. Also used to access the Table and Bids
     *  @param team the index of the team that this sprite is for
     *  @param lastTrickPos the relative position of the scaled down last trick icon 
     *  @param height the height of the background image, needed for layout
     *  @param background the embedded class containing the background image
     *  @param nameTextColor the color of the player names text
     *  @param nameTextOutlineColor the color of the outline applied to the player names
     *  @param scoreTextColor the color of the score (and trick) text
     *  @param scoreTextOutlineColor the color of the score (and trick) text outline
     *  @param labelTextColor the color of the score (and trick) label text
     *  @param labelTextOutlineColor the color of the score (and trick) label text outline */
    public function TeamSprite (
        scores :Scores,
        team :int,
        height :int,
        lastTrickPos :Vector2,
        background :Class,
        nameTextColor :uint,
        nameTextOutlineColor :uint,
        scoreTextColor :uint,
        scoreTextOutlineColor :uint,
        labelTextColor :uint,
        labelTextOutlineColor :uint)
    {
        MultiLoader.getContents(background, gotBackground);

        _table = scores.table;
        _team = _table.getTeam(team);
        _bids = scores.bids;
        _scores = scores;
        _lastTrickPos = lastTrickPos.clone();

        _lastTrick = new LastTrickSprite();
        addChild(_lastTrick);

        var nameField :Text = new Text(Text.SMALL, 
            nameTextColor, nameTextOutlineColor);
        nameField.centerY = -height / 3;
        nameField.text = makeNameString(
            _table.getNameFromAbsolute(_team.players[0]), 
            _table.getNameFromAbsolute(_team.players[1]));
        addChild(nameField);

        _score = new ScoreBar("Score:", [-30, 10, 15, 20], scoreTextColor, 
            scoreTextOutlineColor, labelTextColor, labelTextOutlineColor);
        _score.x = 0;
        _score.y = -5;
        addChild(_score);

        _tricks = new ScoreBar("Tricks:", [-15, 10, 15, 20], scoreTextColor, 
            scoreTextOutlineColor, labelTextColor, labelTextOutlineColor);
        _tricks.x = 0;
        _tricks.y = height / 2 - 20;
        addChild(_tricks);

        updateTricks();
        setScore(_scores.getScore(_team.index), _scores.target);

        _bids.addEventListener(BidEvent.RESET, bidListener);
        _bids.addEventListener(BidEvent.PLACED, bidListener);

        _scores.addEventListener(ScoresEvent.TRICKS_CHANGED, scoresListener);
        _scores.addEventListener(ScoresEvent.SCORES_CHANGED, scoresListener);
        _scores.addEventListener(ScoresEvent.SCORES_RESET, scoresListener);
        _scores.addEventListener(ScoresEvent.TRICKS_RESET, scoresListener);

        function gotBackground (background :Bitmap) :void
        {
            addChildAt(background, 0);

            background.x = -background.width / 2;
            background.y = -background.height / 2;
        }
    }

    /** Take the array of card sprites and animate them to this team's last trick slot. The 
     *  animation includes x,y position and scale. 
     *  @param cards the trick just won
     *  @param winnerPos the global coordinates of the position of the winning player */
    public function takeTrick (
        cards :Array, 
        mainTrickPos :Vector2,
        winnerPos :Vector2) :void
    {
        // get the starting position in local coordinates
        var localStartPos :Vector2 = Vector2.fromPoint(
            globalToLocal(mainTrickPos.toPoint()));

        // get the winner position in local coordinates
        winnerPos = Vector2.fromPoint(globalToLocal(winnerPos.toPoint()));

        // reset the last trick before tweening
        _lastTrick.setCards(cards);
        _lastTrick.x = localStartPos.x;
        _lastTrick.y = localStartPos.y;
        _lastTrick.scaleX = 1.0;
        _lastTrick.scaleY = 1.0;

        // shrink on the way to the winner position
        LocalTweener.addTween(_lastTrick, {
            scaleX: TRICK_SCALE,
            scaleY: TRICK_SCALE,
            time: MAIN_TO_WINNER_DURATION
        });

        // slide to the winner position
        LocalTweener.addTween(_lastTrick, {
            x: winnerPos.x,
            y: winnerPos.y,
            time: MAIN_TO_WINNER_DURATION - SLIDE_DELAY,
            delay: SLIDE_DELAY,
            transition: "easeInOutQuad"
        });

        function snapTo () :void {
            _lastTrick.alpha = 1.0;
            _lastTrick.x = _lastTrickPos.x;
            _lastTrick.y = _lastTrickPos.y;
        }

        // fade out afterwards
        LocalTweener.addTween(_lastTrick, {
            alpha: 0.0,
            time: FADE_DURATION,
            delay: MAIN_TO_WINNER_DURATION - FADE_DURATION / 2,
            onComplete: snapTo
        });
    }

    /** Clear the card sprites. */
    public function clearLastTrick () :void
    {
        _lastTrick.clear();
    }

    /** Set the team's score display. */
    protected function setScore (current :int, target :int) :void
    {
        _score.setValues(current, target);
    }

    /** Update the tricks/bid status text. */
    protected function updateTricks () :void
    {
        var tricks :int = _scores.getTricks(_team.index);
        var seats :Array = _team.players;

        if (!_bids.hasBid(seats[0]) || !_bids.hasBid(seats[1])) {
            _tricks.setValues(tricks, "?");
        }
        else {
            var bid :int = _bids.getBid(seats[0]) + _bids.getBid(seats[1]);
            _tricks.setValues(tricks, bid);
        }
    }

    protected function bidListener (event :BidEvent) :void
    {
        if (event.type == BidEvent.RESET) {
            updateTricks();
        }
        else if (event.type == BidEvent.PLACED) {
            updateTricks();
        }
    }

    protected function scoresListener (event :ScoresEvent) :void
    {
        if (event.team == _team) {
            if (event.type == ScoresEvent.TRICKS_CHANGED) {
                updateTricks();
            }
            else if (event.type == ScoresEvent.SCORES_CHANGED) {
                setScore(event.value, _scores.target);
            }
        }
        else if (event.type == ScoresEvent.TRICKS_RESET) {
            updateTricks();
        }
        else if (event.type == ScoresEvent.SCORES_RESET) {
            setScore(0, _scores.target);
        }
    }

    /** Utility function to truncate and concatenate two names. */
    protected static function makeNameString (
        name1: String, 
        name2 :String) :String
    {
        name1 = Text.truncName(name1);
        name2 = Text.truncName(name2);
        return name1 + "/" + name2;
    }

    /** The table we are sitting at */
    protected var _table :Table;

    /** The seats of our team members */
    protected var _team :Team;

    /** The bids for the game */
    protected var _bids :Bids;

    /** The scores for the game */
    protected var _scores :Scores;

    /** Sprite for the last trick display */
    protected var _lastTrick :LastTrickSprite;

    /** Static position of our last trick display */
    protected var _lastTrickPos :Vector2;

    /** Tricks score, e.g. "1/5" */
    protected var _tricks :ScoreBar;

    /** Score score, e.g. "172/300" */
    protected var _score :ScoreBar;

    protected static const TRICK_SCALE :Number = 0.5;
    protected static const MAIN_TO_WINNER_DURATION :Number = 1.5;
    protected static const FADE_DURATION :Number = .5;
    protected static const SLIDE_DELAY :Number = .5;
}

}

import flash.display.Sprite;
import com.whirled.contrib.card.graphics.Text;

/** Contains the 4 text components that make up "Scores" or "Tricks": the label, the score value, 
 *  the slash and the target score value */
class ScoreBar extends Sprite
{
    public static const WHITE :uint = 0xFFFFFF;

    /** @param xpositions x offsets of label, score, slash and target
     *  @param colors the color of the score text and the label outline, in order */
    public function ScoreBar (
        label :String, 
        xpositions :Array, 
        scoreTextColor :uint,
        scoreTextOutlineColor :uint,
        labelTextColor :uint,
        labelTextOutlineColor :uint)
    {
        var text :Text;

        text = new Text(Text.HUGE, scoreTextColor, scoreTextOutlineColor);
        text.centerY = 0;
        text.x = xpositions[1];
        text.text = "";
        text.rightJustify();
        addChild(_score = text);

        text = new Text(Text.HUGE, scoreTextColor, scoreTextOutlineColor);
        text.centerY = 0;
        text.x = xpositions[2];
        text.text = "/";
        addChild(text);

        text = new Text(Text.HUGE, scoreTextColor, scoreTextOutlineColor);
        text.centerY = 0;
        text.x = xpositions[3];
        text.text = "";
        text.leftJustify();
        addChildAt(_target = text, 0);

        text = new Text(Text.SMALL_ITALIC, labelTextColor, labelTextOutlineColor);
        text.bottomY = _score.bottomY;
        text.x = xpositions[0];
        text.text = label;
        text.rightJustify();
        addChild(text);
    }

    /** Set the current and target score. */
    public function setValues (score :int, target :Object) :void
    {
        _score.text = "" + score;
        _target.text = "" + target;
    }

    protected var _score :Text;
    protected var _target :Text;
}
