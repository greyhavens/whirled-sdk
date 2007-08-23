//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.data {

import com.threerings.io.ObjectInputStream;

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

    // from interface WhirledGame
    public function getWhirledGameService () :WhirledGameMarshaller
    {
        return whirledGameService;
    }

    override protected function readDefaultFields (ins :ObjectInputStream) :void
    {
        super.readDefaultFields(ins);

        whirledGameService = (ins.readObject() as WhirledGameMarshaller);
    }
}
}
