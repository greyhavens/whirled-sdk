//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

import com.threerings.ezgame.AbstractGameControl;
import com.threerings.ezgame.EZLocalSubControl;
import com.threerings.ezgame.EZNetSubControl;
import com.threerings.ezgame.EZPlayerSubControl;
import com.threerings.ezgame.EZGameSubControl;
import com.threerings.ezgame.EZServicesSubControl;

/**
 * The primary class used to coordinate game state and control your multiplayer game.
 *
 * (Are you viewing the <a href="/code/WhirledGameControl.html" target="_top">Easy
 *   WhirledGameControl Index</a>?)
 *
 * Typically, you create this in your top-level MovieClip/Sprite:
 * <code>
 * public class MyGame extends Sprite
 * {
 *     public var ctrl :WhirledGameControl;
 *
 *     // Constructor
 *     public function MyGame ()
 *     {
 *          ctrl = new WhirledGameControl(this);
 *          ...
 * </code>
 */
public class WhirledGameControl extends AbstractGameControl
{
    /**
     * Creates a control and connects to the Whirled game system.
     *
     * @param disp the display object that is the game's UI.
     * @param autoReady if true, the game will automatically be started when initialization is
     * complete, if false, the game will not start until all clients call playerReady().
     *
     * @see com.threerings.ezgame.EZGameControl#playerReady()
     */
    public function WhirledGameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        super(disp, autoReady);
    }

    /**
     * Access the 'local' services.
     */
    public function get local () :LocalSubControl
    {
        return _localCtrl as LocalSubControl;
    }

    /**
     * Access the 'net' services.
     */
    public function get net () :EZNetSubControl
    {
        return _netCtrl;
    }

    /**
     * Access the 'player' services.
     */
    public function get player () :PlayerSubControl
    {
        return _playerCtrl as PlayerSubControl;
    }

    /**
     * Access the 'game' services.
     */
    public function get game () :GameSubControl
    {
        return _gameCtrl as GameSubControl;
    }

    /**
     * Access the 'services' services.
     */
    public function get services () :EZServicesSubControl
    {
        return _servicesCtrl;
    }

    /**
     * @private
     */
    override protected function createLocalControl () :EZLocalSubControl
    {
        return new LocalSubControl(this);
    }

    /**
     * @private
     */
    override protected function createPlayerControl () :EZPlayerSubControl
    {
        return new PlayerSubControl(this);
    }

    /**
     * @private
     */
    override protected function createGameControl () :EZGameSubControl
    {
        return new GameSubControl(this);
    }
}
}
