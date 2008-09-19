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
import flash.display.DisplayObject;
import flash.display.Bitmap;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import com.threerings.util.MultiLoader;
import com.whirled.contrib.card.Team;
import com.whirled.contrib.card.TurnTimer;
import com.whirled.contrib.card.TurnTimerEvent;
import com.whirled.contrib.card.Table;

/**
 * Flash object for a player sitting at a trick-taking card game. This is a placeholder for 
 * something nicer, so only the interface is documented in detail.
 */
public class PlayerSprite extends Sprite
{
    /** Create a new player. 
     *  @param table the table for the game the player is playing
     *  @param id the id of the player this sprite represents
     *  @param timer the turn timer model object 
     *  @param timerMovie the embedded movie for the turn timer 
     *  @param timerPos the position of the timer relative to the center of the player sprite
     *  @param background the embedded background object
     *  @param textColor the color of the text of the player's name
     *  @param outlineColor the color of the outline of the text
     *  @param width the width of the background image
     *  @param height the height of the background image
     *  @param warningColor the color of the caption text when it is a warning
     *  @param captionColor the color of the caption text normally
     *  @param captionOutlineColor the color of the outline of the caption text
     *  */
    public function PlayerSprite (
        table :Table,
        id :int, 
        width :int,
        height :int,
        timer :TurnTimer,
        timerMovie :Class,
        timerPos :Point,
        background :Class,
        textColor :uint,
        outlineColor :uint,
        warningColor :uint,
        captionColor :uint,
        captionOutlineColor :uint)
    {
        _team = table.getTeamFromId(id);
        _id = id;

        _warningColor = warningColor;
        _captionColor = captionColor;
        _captionOutlineColor = captionOutlineColor;
        _height = height;

        // TODO: fix drop shadow
        _headShot = new HeadShotContainer();
        addChild(_headShot);

        _timer = new TimerMovie(timerMovie);
        _timer.x = timerPos.x;
        _timer.y = timerPos.y;
        _timer.alpha = 0.0;
        addChild(_timer);

        MultiLoader.getContents(background, gotBackground);

        var nameField :Text = new Text(
            Text.BIG, textColor, outlineColor);
        addChild(nameField);

        nameField.centerY = -height / 3;
        nameField.text = Text.truncName(table.getNameFromId(id));

        setTurn(false);

        timer.addEventListener(TurnTimerEvent.STARTED, turnTimerListener);

        function gotBackground (background :Bitmap) :void
        {
            _background = background;
            addChildAt(_background, 0);

            _background.x = -_background.width / 2;
            _background.y = -_background.height / 2;

            _background.alpha = _turn ? 1.0 : 0.0;
        }
    }

    /** Set the player head shot. */
    public function setHeadShot (headShot :DisplayObject) :void
    {
        var alpha :Number = _turn ? 0.0 : DROP_SHADOW_MAX_ALPHA;
        _headShot.setImage(headShot, new DropShadowFilter(
            6, 45, 0x000000, alpha, 10, 10, 2));
    }

    /** Update to reflect the turn status.
     *  @param turn indicates whether it is this player's turn */
    public function setTurn (turn :Boolean) :void
    {
        _turn = turn;

        if (_background == null) {
            return;
        }

        _timer.stop();
        if (turn) {
            _timer.reset();
        }

        LocalTweener.removeTweens(_background);
        LocalTweener.removeTweens(_timer);
        LocalTweener.removeTweens(_headShot);

        var tween :Object = {alpha : turn ? 1.0 : 0.0, time : 1.0};

        LocalTweener.addTween(_background, tween);
        LocalTweener.addTween(_timer, tween);
        LocalTweener.addTween(_headShot, {
            dropShadowAlpha : turn ? 0.0 : DROP_SHADOW_MAX_ALPHA,
            time : 1.0
        });
    }

    /** Display a warning for this player. 
     *  TODO: make protected and listen for warning events in subclasses. */
    public function showCaption (str :String, warning :Boolean=false) :void
    {
        if (_caption != null) {
            removeChild(_caption);
            _caption = null;
        }

        if (str.length > 0) {
            var fcolor :uint = warning ? _warningColor : _captionColor;
            var bcolor :uint = _captionOutlineColor;
            _caption = new Text(Text.BIG, fcolor, bcolor);
            _caption.centerY = _height / 3;
            _caption.text = str;
            addChild(_caption);
        }
    }

    protected function turnTimerListener (event :TurnTimerEvent) :void
    {
        if (event.type == TurnTimerEvent.STARTED) {
            if (event.player == _id) {
                _timer.start(event.time);
            }
        }
    }

    protected var _team :Team;
    protected var _id :int;
    protected var _background :Bitmap;
    protected var _headShot :HeadShotContainer;
    protected var _turn :Boolean;
    protected var _caption :Text;
    protected var _timer :TimerMovie;
    protected var _warningColor :uint;
    protected var _captionColor :uint;
    protected var _captionOutlineColor :uint;
    protected var _height :int;

    protected static const DROP_SHADOW_MAX_ALPHA :Number = 0.5;
}

}


import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.filters.DropShadowFilter;

/** Contains a player's head shot and manages the alpha of the drop shadow filter as a property
 *  (this is otherwise quite annoying and ugly to do with Tweener). */
class HeadShotContainer extends Sprite
{
    /** Creates a new empty head shot container. */
    public function HeadShotContainer ()
    {
    }

    /** Set the head shot to use inside the container.
     *  @param headShot the image to use
     *  @param filter the drop shadow filter to be assigned to the head shot */
    public function setImage (
        headShot :DisplayObject, 
        filter :DropShadowFilter) :void
    {
        if (_image != null) {
            removeChild(_image);
            _image = null;
        }

        _image = headShot;

        if (_image != null) {
            _image.x = -_image.width / 2;
            _image.y = -_image.height / 2;
            _image.filters = [filter]
            addChild(_image);
        }
    }

    /** Access the alpha property of the drop shadow filter. Automatically takes care of
     *  reinitializing the head shot's filter array. */
    public function set dropShadowAlpha (alpha :Number) :void
    {
        if (_image == null) {
            return;
        }

        // the filter cannot be modified directly, only on a temporary array
        // (see adobe docs for DisplayObject.filters)
        var f :Array = _image.filters;
        f[0].alpha = alpha;
        _image.filters = f;
    }

    /** Access the alpha property of the drop shadow filter (required for tweening). */
    public function get dropShadowAlpha () :Number
    {
        if (_image == null) {
            return 0;
        }
        return _image.filters[0].alpha;
    }

    protected var _image :DisplayObject;
}

