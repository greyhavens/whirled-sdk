//
// $Id$

package com.whirled.xml;

import java.util.ArrayList;

import org.apache.commons.digester.ObjectCreateRule;

import com.threerings.ezgame.xml.GameParser;

import com.whirled.data.WhirledGameDefinition;


/**
 * Customizes the EZ game parser for the Whirled test server.
 */
public class WhirledGameParser extends GameParser
{
    public WhirledGameParser ()
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
        return WhirledGameDefinition.class.getName();
    }
}
