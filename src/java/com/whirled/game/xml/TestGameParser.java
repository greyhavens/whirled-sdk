//
// $Id$
//
// Copyright (c) 2007-2011 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.xml;

import java.util.ArrayList;

import org.apache.commons.digester.ObjectCreateRule;

import com.whirled.game.data.ItemPackParameter;
import com.whirled.game.data.LevelPackParameter;
import com.whirled.game.data.TestGameDefinition;


/**
 * Customizes the game parser for the Whirled test server.
 */
public class TestGameParser extends WhirledGameParser
{
    public TestGameParser ()
    {
        super();

        _digester.addRule("game/packs", new ObjectCreateRule(ArrayList.class));
        _digester.addSetNext("game/packs", "setPacks", ArrayList.class.getName());
        addParameter("game/packs/item", ItemPackParameter.class);
        addParameter("game/packs/level", LevelPackParameter.class);
    }
    
    @Override // from GameParser
    protected String getGameDefinitionClass ()
    {
        return TestGameDefinition.class.getName();
    }
}
