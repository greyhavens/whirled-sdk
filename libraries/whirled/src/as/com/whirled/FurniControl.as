//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

/**
 * Dispatched when the local user hovers the mouse over this sprite.
 * Note that normal MouseEvents are blocked when this sprite has "action", like it
 * is a doorway. If you want the doorway to react to the mouse being over it then
 * you should listen for this event.
 *
 * @eventType com.whirled.ControlEvent.HOVER_OVER
 */
[Event(name="hoverOver", type="com.whirled.ControlEvent")]

/**
 * Dispatched when the local user unhovers the mouse from this sprite.
 * Note that normal MouseEvents are blocked when this sprite has "action", like it
 * is a doorway. If you want the doorway to react to the mouse being over it then
 * you should listen for this event.
 *
 * @eventType com.whirled.ControlEvent.HOVER_OVER
 */
[Event(name="hoverOut", type="com.whirled.ControlEvent")]

/**
 * This file should be included by furniture, so that it can communicate
 * with the whirled.
 */
public class FurniControl extends EntityControl
{
    /** An action triggered when someone arrives at the location at which
     * this furniture is placed, if this piece of furniture is a doorway.
     *
     * This will arrive via an ACTION_TRIGGERED event with the name property set
     * to BODY_ENTERED.
     */
    public static const BODY_ENTERED :String = "bodyEntered";

    /** An action triggered when someone leaves via this piece of doorway
     * furniture.
     *
     * This will arrive via an ACTION_TRIGGERED event with the name property set
     * to BODY_LEFT.
     */
    public static const BODY_LEFT :String = "bodyLeft";

    /**
     * Create a furni interface. The display object is your piece
     * of furni.
     */
    public function FurniControl (disp :DisplayObject)
    {
        super(disp);
        disp.root.addEventListener(MouseEvent.ROLL_OVER, handleMouseRoll);
        disp.root.addEventListener(MouseEvent.ROLL_OUT, handleMouseRoll);
    }

    /**
     * Register a function used for generating a custom config panel. This will
     * be called when this piece of furniture is being edited inside whirled.
     *
     * @param func signature: function () :DisplayObject
     * Your function should return a DisplayObject as a configuration panel.
     * The width/height of the object at return time will be used to configure the amount
     * of space given it. Any changes made by the user should effect immediately, or
     * you should provide buttons to apply the change, if absolutely necessary.
     */
    public function registerCustomConfig (func :Function) :void
    {
        _customConfig = func;
    }

    /**
     * @private
     */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["getConfigPanel_v1"] = getConfigPanel_v1;
        o["mouseHover_v1"] = mouseHover_v1;
    }

    /**
     * Called when whirled is editing this furniture, to retrieve any custom configuration
     * panel.
     * @private
     */
    protected function getConfigPanel_v1 () :DisplayObject
    {
        // TODO: make this dispatch an event that receives the config in a method
        return (_customConfig != null) ? (_customConfig() as DisplayObject) : null;
    }

    /**
     * Dispatches hover events.
     * @private
     */
    protected function mouseHover_v1 (over :Boolean) :void
    {
        dispatchCtrlEvent(over ? ControlEvent.HOVER_OVER : ControlEvent.HOVER_OUT);
    }

    /**
     * @private
     */
    protected function handleMouseRoll (event :MouseEvent) :void
    {
        // when we don't have action in whirled, we need to hand-dispatch these events
        // but when we do have action, we won't receive normal mouse events and we'll be
        // getting our HOVERs from whirled.
        mouseHover_v1(event.type == MouseEvent.ROLL_OVER);
    }

    /** A function registered to return a custom configuration panel. @private */
    protected var _customConfig :Function;
}
}
