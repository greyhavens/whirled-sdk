//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.TypedArray;

import com.threerings.ezgame.data.EZGameObject;

/**
 * Used when testing games with the SDK.
 */
public class TestGameObject extends EZGameObject
    implements WhirledGame
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>whirledGameService</code> field. */
    public static const WHIRLED_GAME_SERVICE :String = "whirledGameService";
    // AUTO-GENERATED: FIELDS END

    /** The whirled game services. */
    public var whirledGameService :WhirledGameMarshaller;

    /** The set of level packs available to this game. */
    public var levelPacks :TypedArray /*LevelInfo*/;

    /** The set of item packs available to this game. */
    public var itemPacks :TypedArray /*ItemInfo*/;

    // from interface WhirledGame
    public function getWhirledGameService () :WhirledGameMarshaller
    {
        return whirledGameService;
    }

    // from interface WhirledGame
    public function getLevelPacks () :Array
    {
        return levelPacks;
    }

    // from interface WhirledGame
    public function getItemPacks () :Array
    {
        return itemPacks;
    }

    // from interface WhirledGame
    public function occupantOwnsItemPack (ident :String, occupant :int) :Boolean
    {
        return false; // TODO
    }

    override protected function readDefaultFields (ins :ObjectInputStream) :void
    {
        super.readDefaultFields(ins);

        whirledGameService = (ins.readObject() as WhirledGameMarshaller);
        levelPacks = (ins.readObject() as TypedArray);
        itemPacks = (ins.readObject() as TypedArray);
    }
}
}
